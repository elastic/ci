#!/usr/bin/env ruby
# Licensed to Elasticsearch under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance  with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on
# an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific
# language governing permissions and limitations under the License
#

require 'rubygems'

require 'log4r'
require 'optparse'
require 'yaml'

include Log4r

L = Logger.new 'generate url'
L.level = INFO
L.outputters = Outputter.stdout


C = {:file_name => 'client_tests_urls.prop', :branch => 'master'}


OptionParser.new do |opts|
  opts.banner = "Usage: generate_es_url.rb [options]"

  opts.on("-b", "--branch [BRANCH]", "ES branch") do |b|
    C[:branch] = b
  end
  opts.on("-d", "--debug", "Debug mode") do |d|
    L.level = DEBUG
  end

  opts.on("-f", "--filename [FILENAME]", "URL File") do |f|
    C[:file_name] = f
  end

end.parse!

def parse_url_file(file_name)
  File.open(file_name, "r") do |file|
    properties = file.readlines.map do |data|
      case
        when data.match(/^\s*#/)
           nil
        when data.match(/^\s+$/)
           nil
        else
           data
      end
    end.compact.map do |data|
      data.chomp.split('=', 2)
    end
    Hash[properties.map {|key, value| [key, value]}]
  end
end

def parse_branch(es_branch)
  # get the last part
  branch = es_branch.chomp.split(/-|\//).last
end

def generate_url(es_branch, url_mapping)
  parsed_branch = parse_branch(es_branch)  
  url_index = 'URL_' + parsed_branch.upcase.gsub(/\./, '')
  url_index = 'URL_1x' if url_index == 'URL_1X' # for 1x branch it is actually URL_1X..needed to be fixed..
  url = url_mapping[url_index]
  unless url 
    url = url_mapping['URL_TAGS'] % parsed_branch.split('v').last
  end
  url
end

L.debug("configuration %s" % YAML.dump(C))
L.debug("url file name %s" % C[:file_name])
L.debug("property hash %s" % YAML.dump(parse_url_file(C[:file_name])))
puts generate_url(C[:branch], parse_url_file(C[:file_name]))
