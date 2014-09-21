#!/usr/bin/env ruby

raise "Bad Arguments" unless ARGV.length == 2

src_dir = ARGV.shift
targ_dir = ARGV.shift

puts "Reading from #{src_dir} / writing to #{targ_dir}"

unless File.directory?(targ_dir)
  Dir.mkdir(targ_dir)
end

# http://www.w3.org/TR/html4/sgml/entities.html
map = {
  'nbsp' => "&#160;",
  'iexcl' => "&#161;",
  'cent' => "&#162;",
  'pound' => "&#163;",
  'curren' => "&#164;",
  'yen' => "&#165;",
  'brvbar' => "&#166;",
  'sect' => "&#167;",
  'uml' => "&#168;",
  'copy' => "&#169;",
  'ordf' => "&#170;",
  'laquo' => "&#171;",
  'not' => "&#172;",
  'shy' => "&#173;",
  'reg' => "&#174;",
  'macr' => "&#175;",
  'deg' => "&#176;",
  'plusmn' => "&#177;",
  'sup2' => "&#178;",
  'sup3' => "&#179;",
  'acute' => "&#180;",
  'micro' => "&#181;",
  'para' => "&#182;",
  'middot' => "&#183;",
  'cedil' => "&#184;",
  'sup1' => "&#185;",
  'ordm' => "&#186;",
  'raquo' => "&#187;",
  'frac14' => "&#188;",
  'frac12' => "&#189;",
  'frac34' => "&#190;",
  'iquest' => "&#191;",
  'Agrave' => "&#192;",
  'Aacute' => "&#193;",
  'Acirc' => "&#194;",
  'Atilde' => "&#195;",
  'Auml' => "&#196;",
  'Aring' => "&#197;",
  'AElig' => "&#198;",
  'Ccedil' => "&#199;",
  'Egrave' => "&#200;",
  'Eacute' => "&#201;",
  'Ecirc' => "&#202;",
  'Euml' => "&#203;",
  'Igrave' => "&#204;",
  'Iacute' => "&#205;",
  'Icirc' => "&#206;",
  'Iuml' => "&#207;",
  'ETH' => "&#208;",
  'Ntilde' => "&#209;",
  'Ograve' => "&#210;",
  'Oacute' => "&#211;",
  'Ocirc' => "&#212;",
  'Otilde' => "&#213;",
  'Ouml' => "&#214;",
  'times' => "&#215;",
  'Oslash' => "&#216;",
  'Ugrave' => "&#217;",
  'Uacute' => "&#218;",
  'Ucirc' => "&#219;",
  'Uuml' => "&#220;",
  'Yacute' => "&#221;",
  'THORN' => "&#222;",
  'szlig' => "&#223;",
  'agrave' => "&#224;",
  'aacute' => "&#225;",
  'acirc' => "&#226;",
  'atilde' => "&#227;",
  'auml' => "&#228;",
  'aring' => "&#229;",
  'aelig' => "&#230;",
  'ccedil' => "&#231;",
  'egrave' => "&#232;",
  'eacute' => "&#233;",
  'ecirc' => "&#234;",
  'euml' => "&#235;",
  'igrave' => "&#236;",
  'iacute' => "&#237;",
  'icirc' => "&#238;",
  'iuml' => "&#239;",
  'eth' => "&#240;",
  'ntilde' => "&#241;",
  'ograve' => "&#242;",
  'oacute' => "&#243;",
  'ocirc' => "&#244;",
  'otilde' => "&#245;",
  'ouml' => "&#246;",
  'divide' => "&#247;",
  'oslash' => "&#248;",
  'ugrave' => "&#249;",
  'uacute' => "&#250;",
  'ucirc' => "&#251;",
  'uuml' => "&#252;",
  'yacute' => "&#253;",
  'thorn' => "&#254;",
  'yuml' => "&#255;",
  'circ' => "&#710;",
  'tilde' => "&#732;",  
  'ensp' => "&#8194;",
  'emsp' => "&#8195;",
  'thinsp' => "&#8201;",
  'zwnj' => "&#8204;",
  'zwj' => "&#8205;",
  'lrm' => "&#8206;",
  'rlm' => "&#8207;",
  'ndash' => "&#8211;",
  'mdash' => "&#8212;",
  'lsquo' => "&#8216;",
  'rsquo' => "&#8217;",
  'sbquo' => "&#8218;",
  'ldquo' => "&#8220;",
  'rdquo' => "&#8221;",
  'bdquo' => "&#8222;",
  'dagger' => "&#8224;",
  'Dagger' => "&#8225;",
  'permil' => "&#8240;",
  'lsaquo' => "&#8249;",
  'rsaquo' => "&#8250;",
  'euro' => "&#8364;",

  # Other characters:
  'cacute' => "&#x0107;",
  'nacute' => '&#324;',
  'Prime' => '&#x2033;',
  'rarr' => '&#8594;',
  'bull' => '&#8226;',
  'prime' => '&#8242;',
  'racute' => '&#341;',
  'frac38' => '&#8540;',
  'hearts' => '&#9829;',
  'zacute' => '&#378;',
  'ncedil' => '&#326;',
  'amacr' => '&#257;',
  'lang' => '&#9001;',
  'rang' => '&#9002;',
  'scaron' => '&#353;',
  'Ccaron' => '&#268;',
  'zcaron' => '&#382;',
  'scaron' => '&#353;',
  'Zcaron' => '&#381;',
  'gt' => '&amp;gt;',
  'lt' => '&amp;lt;',
  '#60' => '&amp;lt;'
}


Dir.glob("#{src_dir}/*.xml") do |file|
  puts file

  outfile = "#{targ_dir}/#{file.sub(/.*\//, '')}"
  File.open(outfile, 'w') do |out|
    str = IO.read(file)

    map.each do |alpha, num|
      str.gsub!("&#{alpha};", num)
    end

    out << str
  end

end

