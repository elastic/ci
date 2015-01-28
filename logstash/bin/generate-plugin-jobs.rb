require "clamp"
require "cabin"
require "octokit"
require "mustache"

Class.new(Clamp::Command) do
  option "--log-level", "LOG_LEVEL", "The log level", :default => :warn
  parameter "[PLUGIN_TYPE]", "The type of the plugin"
  parameter "[PLUGIN_NAME]", "The name of the plugin"
  
  def logger
    @logger ||= Cabin::Channel.get
  end

  def execute
    logger.subscribe(STDOUT)
    logger.level = log_level

    if plugin_type.nil?
      logger.info("No plugin type given. Searching for all plugins.")
    elsif plugin_name.nil?
      logger.info("No plugin name given. Fetching all plugins by type.", :type => plugin_type)
    else
      jobs = [ LogstashPluginJenkinsJob.new(plugin_type, plugin_name) ]
    end
  end
end.run
