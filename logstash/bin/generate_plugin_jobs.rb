require "clamp"
require "cabin"
require "octokit"
require "mustache"
require_relative "../lib/jenkins_job"

Class.new(Clamp::Command) do
  option "--log-level", "LOG_LEVEL", "The log level", :default => :warn
  option "--organization", "ORGANIZATION", "The github org to list repositories", :default => "logstash-plugins"
  option "--jenkins-home", "JENKINS_HOME", "The path to the JENKINS_HOME", :required => true
  parameter "[PLUGIN_TYPE]", "The type of the plugin"
  parameter "[PLUGIN_NAME]", "The name of the plugin"
  
  def logger
    @logger ||= Cabin::Channel.get
  end

  def execute
    logger.subscribe(STDOUT)
    logger.level = log_level.to_sym

    jobs = compute_plugin_jobs

    jobs.each do |job|
      File.join(jenkins_home, job.job_dir).tap do |dir|
        Dir.mkdir(dir) if !File.directory?(dir)
      end
      File.write(File.join(jenkins_home, job.config_xml_path), JobRenderer.render(job))
    end
  end

  def compute_plugin_jobs
    Octokit.auto_paginate = true
    if plugin_type.nil?
      logger.info("No plugin type given. Searching for all plugins.")
      repositories = list_repositories(organization)
    elsif plugin_name.nil?
      logger.info("No plugin name given. Fetching all plugins by type.", :type => plugin_type)
      re = Regexp.new("^logstash-#{plugin_type}-")
      repositories = list_repositories(organization).grep(re)
    else
      repositories = ["logstash-#{plugin_type}-#{plugin_name}"]
    end
    repositories.collect { |r| r.gsub(/^logstash-/, "").split("-") }.collect { |(t, n)| LogstashPluginJenkinsJob.new(t, n) }
  end

  def client
    return @client if @client
    @client = Octokit::Client.new
    @client
  end

  def list_repositories(org)
    client.organization_repositories(org).collect { |r| r[:name] }
  end
end.run
