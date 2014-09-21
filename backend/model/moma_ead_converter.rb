class MomaEADConverter < EADConverter

  def self.import_types(show_hidden = false)
    [
     {
       :name => "moma_ead_xml",
       :description => "Import MOMA EAD records from an XML file"
     }
    ]
  end


  def self.instance_for(type, input_file)
    if type == "moma_ead_xml"
      self.new(input_file)
    else
      nil
    end
  end

  def self.profile
    "Convert EAD To ArchivesSpace JSONModel records"
  end

  def self.configure
    super

    # c, c1, c2, etc...
    (0..12).to_a.map {|i| "c" + (i+100).to_s[1..-1]}.push('c').each do |c|
      with c do
        make :archival_object, {
          :level => att('level') || 'file',
          :other_level => att('otherlevel'),
          :ref_id => att('id'),
          :resource => ancestor(:resource),
          :parent => ancestor(:archival_object),
          :publish => att('audience') != 'internal'
        }
      end
    end

    with 'subtitle' do
      ancestor(:resource) do |r|
        r.finding_aid_title << inner_xml.sub(/^/, "<lb />")
      end
    end


    with 'eadid' do
      set :ead_id, inner_xml
      set :ead_location, att('url')
      set :id_0, inner_xml
    end


    with 'unitid' do |node|
      ancestor(:note_multipart, :resource, :archival_object) do |obj|
        case obj.class.record_type
        when 'resource'
       #   set obj, :id_0, inner_xml
        when 'archival_object'
          set obj, :component_id, inner_xml.gsub(/[\/_\-.]/, '_')
        end
      end
    end

    with 'unittitle' do |node|
      ancestor(:resource, :archival_object) do |obj|
        obj.title = node.inner_xml.strip.sub(/<unitdate[^>]*>[^<]*<\/unitdate>/, '').gsub(/<unitdate\/>/, '').gsub(/[^:;]\s?<lb\s?\/>/, "; ").gsub(/([:;])\s?<lb\s?\/>/, '\1 ')
      end
    end

    with 'unitdate' do |node|

      norm_dates = (att('normal') || "").sub(/^\s/, '').sub(/\s$/, '').split('/')
      if norm_dates.length == 1
        norm_dates[1] = norm_dates[0]
      end
      norm_dates.map! {|d| d =~ /^([0-9]{4}(\-(1[0-2]|0[1-9])(\-(0[1-9]|[12][0-9]|3[01]))?)?)$/ ? d : nil}
      
      make :date, {
        :date_type => att('type') || 'inclusive', 
        :expression => inner_xml,
        :label => att('label') || 'creation',
        :begin => norm_dates[0],
        :end => norm_dates[1],
        :calendar => att('calendar'),
        :era => att('era'),
        :certainty => att('certainty')
      } do |date|
        set ancestor(:resource, :archival_object), :dates, date
      end
    end


    with 'note' do |node|
      make :note_multipart, {
        :type => 'odd',
        :subnotes => {
          'jsonmodel_type' => 'note_text',
          'content' => inner_xml
        }
      } do | note|
        set ancestor(:archival_object), :notes, note
      end
    end


    with 'physdesc' do
      extent_string = inner_xml.gsub(/<lb\s?\/>/, "\n")

      quantified = case extent_string
                   when /([0-9\.]+)\s+linear\sf(oo|ee)t/
                     [$1, 'linear_feet']
                   when /^\s*([0-9\.]+)\s([a-z\s]+)\s*$/
                     [$1, $2]
                   else 
                     ['0', 'linear_feet']
                   end

      make :extent, {
        :number => quantified.shift,
        :extent_type => quantified.shift,
        :portion => 'whole',
        :container_summary => extent_string
      } do |extent|
        set ancestor(:resource, :archival_object), :extents, extent
      end

    end


    with 'container' do

      if context_obj.instances.empty?
        make :instance, {
          :instance_type => 'mixed_materials'
        } do |instance|
          set ancestor(:resource, :archival_object), :instances, instance
        end
      end

      inst = context == :instance ? context_obj : context_obj.instances.last

      if inst.container.nil?
        make :container do |cont|
          set inst, :container, cont
        end
      end

      cont = inst.container || context_obj

      (1..3).to_a.each do |i|
        next unless cont["type_#{i}"].nil?
        cont["type_#{i}"] = att('type').strip
        cont["indicator_#{i}"] = inner_xml
        if cont["indicator_#{i}"].length == 0
          cont["indicator_#{i}"] = 'BLANK'
        end
        break
      end
    end
  end


  # Override the method that pushes out JSON records
  # in order to set some defaults in cases where 
  # required subrecords aren't picked up in the source
  # record

  def close_context(type)
    if @batch.working_area.last.jsonmodel_type != type.to_s
      raise "Unexpected Object Type in Queue: Expected #{type} got #{@batch.working_area.last.jsonmodel_type}"
    end

    case type.to_s

    when "resource"
      resource = @batch.working_area.last
      unless resource.extents && !resource.extents.empty?
        extent = ASpaceImport::JSONModel(:extent).new
        extent.number = '0'
        extent.extent_type = 'linear_feet'
        extent.portion = 'whole'

        resource.extents << extent
      end
      
    when "archival_object"
      ao = @batch.working_area.last

      unless (ao.title && ao.title.length > 0) || ao.dates.length > 0
        ao.title = "Untitled"
      end

      
    end

    super

  end


  # ignore empty corpname elements
  def make_corp_template(opts)
    super unless inner_xml.empty?
  end


  # Overrides of XML::Sax methods

  #overrides a memory busting method
  def is_node_empty?(node); false; end;
  

  #catch empty nodes here and prevent them from making objects
  def make(type, properties = {})

    case type
    when :note_singlepart
      return if properties[:content].empty?

    when :note_multipart
      return if properties[:subnotes]['content'].empty?

    when :date
      return if properties[:expression].empty? && properties[:begin].nil? && properties[:end].nil?

    when :subject
      return if properties[:terms]['term'].empty?

    end

    super
  end


  def inner_xml
    xml = super
    xml.gsub(/<unitdate\/>/, '')
  end


  # restore older version of node closing logic
  def run
    @reader = Nokogiri::XML::Reader(IO.read(@input_file))
    node_queue = node_queue_for(@reader)
    @contexts = []
    @context_nodes = {}
    @proxies = ASpaceImport::RecordProxyMgr.new
    @stickies = []
    # another hack for noko:
    @node_shadow = nil

    self.class.ensure_configuration

    @reader.each_with_index do |node, i|

      case node.node_type

      when 1

        # Nokogiri Reader won't create events for closing tags on empty nodes
        # https://github.com/sparklemotion/nokogiri/issues/928
        # handle_closer(node) if node.self_closing? #<--- don't do this it's horribly slow
        if @node_shadow && node.depth <= @node_shadow[1]
          handle_closer(@node_shadow)
        end

        handle_opener(node) 
      when 3
        handle_text(node)
      when 15

        # added for cases where an empty node is the
        # last child in a set, hence the next event is
        # type 15
        if @node_shadow && node.depth <= @node_shadow[1]
          handle_closer(@node_shadow)
        end

        handle_closer(node)
      end

      # A gross hack. Use Java Reflection to clear Nokogiri's node queue,
          # since otherwise we end up accumulating all nodes in memory.
      node_queue.set(i, nil)
    end
  end

end
