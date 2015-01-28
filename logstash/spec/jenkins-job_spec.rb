require "jenkins-job"
require "rexml/document"
require "rexml/xpath"
require "stud/try"

describe LogstashPluginJenkinsJob do
  subject(:job) { LogstashPluginJenkinsJob.new("filter", "mutate") }

  describe "#job_name" do
    subject { job.job_name }
    it { should(eq("Logstash Plugin Filter Mutate Commit")) }
  end

  describe "#repo_name" do
    subject { job.repo_name }
    it { should(eq("logstash-filter-mutate")) }
  end

  describe "#project_url" do
    subject { job.project_url }
    it { should(eq("https://github.com/logstash-plugins/logstash-filter-mutate")) }
  end

  describe "#git_url" do
    subject { job.git_url }
    it { should(eq("https://github.com/logstash-plugins/logstash-filter-mutate.git")) }
  end
end

describe JobRenderer do
  describe ".template_path" do
    subject { JobRenderer.template_path }
    let(:fstat) { File.lstat(subject) }
    it "should be a valid file" do
      expect(fstat.file?).to(be_truthy)
    end
    it "should be a file of reasonable size" do
      expect(fstat.size).to(be_within(2000).of(4000))
    end
  end

  describe ".render" do
    let(:job) { LogstashPluginJenkinsJob.new("filter", "mutate") }
    subject(:xml) { JobRenderer.render(job) }

    it "should be a string" do
      expect(xml).to(be_an_instance_of(String))
    end

    describe "for jenkins" do
      subject(:doc) { REXML::Document.new(xml) }
      it "should be valid xml" do
        # REXML::Document.new(x) always is successful. It seems the way to detect if
        # a document was successfully parsed is to check if the document
        # has a non-nil root node.
        expect(doc.root).to_not(be_nil)
      end

      it "should have <project> as the root" do
        expect(doc.root.name).to(eq("project"))
      end

      it "should have an expected <displayName>" do
        actual = REXML::XPath.first(doc, "/project/displayName/text()").value
        expect(actual).to(eq(job.job_name))
      end

      it "should have an expected github project url" do
        actual = REXML::XPath.first(doc, "/project/properties/com.coravy.hudson.plugins.github.GithubProjectProperty/projectUrl/text()").value
        expect(actual).to(eq(job.project_url))
      end

      it "should have an expected git config" do
        git_url = REXML::XPath.first(doc, "/project/scm[@class='hudson.plugins.git.GitSCM']/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url/text()").value
        expect(git_url).to(eq(job.git_url))

        relative_target_dir = REXML::XPath.first(doc, "/project/scm[@class='hudson.plugins.git.GitSCM']/extensions/hudson.plugins.git.extensions.impl.RelativeTargetDirectory/relativeTargetDir/text()").value
        expect(relative_target_dir).to(eq(job.relative_target_dir))
      end

      it "should generate valid shell in build steps" do
        REXML::XPath.each(doc, "/project/builders/*/buildStep[@class='hudson.tasks.Shell']/command/text()") do |node|
          pid = fork
          if pid.nil?
            exec("bash", "-nc", node.value)
            exit 99 # should not get here, but force an exit anyway just in case.
          end

          # Mute stud's logging
          allow(Stud::TRY).to(receive(:log_failure)) { }

          begin
            status = Stud.try(5.times) do
              _, status = Process.waitpid2(pid, Process::WNOHANG)
              raise Errno::EAGAIN if status.nil?
              status
            end
            expect(status.success?).to(be_truthy)
          rescue Errno::EAGAIN
            # Stud.try gave up, kill the subprocess and reraise.
            Process.kill("KILL", pid)
            raise
          end
        end
      end
    end
  end
end
