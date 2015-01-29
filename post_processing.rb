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
# Unified post build processing script
# GZip hprof files
require 'find'

workspace = ARGV[0] || ENV['WORKSPACE']

def gzip_hprof(workspace)
  Find.find(workspace) do |this_file|
    if File.basename(this_file)[0] == '.'
      Find.prune
    else
      if(this_file.end_with?('.hprof','.log')) 
        puts `gzip -fv #{this_file}`
      end
    end
  end
end

def erase_setting(workspace)
  regression_setting = File.join(workspace,'es_regression_setting.xml')
  if(File.exist?(regression_setting))
    File.unlink(regression_setting)
  end
end

gzip_hprof(workspace)
erase_setting(File.join(workspace,'master','ci','pom'))
