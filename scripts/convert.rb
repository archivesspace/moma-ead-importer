#!/usr/bin/env ruby

class Log

  def self.debug(msg)
    puts msg
  end

  def self.warn(msg)
    puts msg
  end
end


apppath = "../../archivesspace-1.0.9/backend/app"

puts $:.unshift("../../archivesspace-1.0.9/common")

require_relative "#{apppath}/converters/converter"
require_relative "#{apppath}/converters/ead_converter"
require_relative "../backend/model/moma_ead_converter"

JSONModel.init(:url => "http://localhost:4567", :client_mode => true)
JSONModel.set_repository(2)


path = File.absolute_path(ARGV[0])

converter = MomaEADConverter.new(path)

begin
  converter.run
rescue JSONModel::ValidationException => e
  puts e.invalid_object
  raise e
end

out = converter.get_output_path

puts JSON.parse(IO.read(out)).join("\n")
