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
# Generate ES setting environment variables for setting and
# launching ES server
#
base_port =  (ENV['EXECUTOR_NUMBER'].to_i || 0) * 100
es_port = base_port + 9500
es_plugin_port = base_port + 10500
es_thrift_port = base_port + 11500
es_args = [
           'es.http.port=%i' % es_port,
           'es.plugin.port=%i' % es_plugin_port,
           'es.thrift.port=%i' % es_thrift_port,
           'es.discovery.zen.ping.multicast.enabled=false',
           'es.logger.level=INFO',
           'es.node.bench=true',
           'es.bootstrap.mlockall=true'
          ]
es_branch = ENV['ES_GIT_BRANCH'] || ENV['ES_V'] || 'origin/master'
property_file_directory = ENV['WORKSPACE'] || Dir.pwd

if(['1.x','master', '1.6'].any? {|x| es_branch.include?(x) } )
  es_args += ['es.script.inline=on', 'es.script.indexed=on', 'es.security.manager.enabled=false']
else
  es_args.push('es.script.disable_dynamic=false')
end

es_args = es_args.map do |line|
  '-D%s' % line
end

es_args = es_args + ['--path.repo /tmp', "--repositories.url.allowed_urls 'http://snapshot.*'"]

test_host = ENV['TESTHOST'] || 'localhost'
mytmpdir='tmp%i' % rand(1000)
File.open(File.join(property_file_directory, 'es_prop.txt'), 'w') do |f|
  f.puts "ES_PORT=%i" % es_port
  f.puts "ES_TEST_HOST=http://%s:%i" % [test_host, es_port]
  f.puts "ES_PLUGIN_PORT=%i" % es_plugin_port
  f.puts "ES_THRIFT_PORT=%i" % es_thrift_port
  f.puts "ES_TMPDIR=%s" % mytmpdir
  f.puts "ES_HEAP_SIZE=1g"
  f.puts "ES_COMMAND_LINE=-d %s" % es_args.join(' ')
end
