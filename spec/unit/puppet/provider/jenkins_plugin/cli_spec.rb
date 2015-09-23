require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_providers'

require 'json'

describe Puppet::Type.type(:jenkins_plugin).provider(:cli) do
  let(:cli_list_plugins_output) do
    <<-EOS
mailer                      Mailer Plugin                             1.11 (1.15)
script-security             Script Security Plugin                    1.13 (1.15)
ldap                        LDAP Plugin                               1.11
junit                       JUnit Plugin                              1.2-beta-4 (1.9)
ssh-slaves                  SSH Slaves plugin                         1.9 (1.10)
cvs                         CVS Plug-in                               2.11 (2.12)
translation                 Translation Assistance plugin             1.10 (1.12)
external-monitor-job        External Monitor Job Type Plugin          1.4
matrix-auth                 Matrix Authorization Strategy Plugin      1.1 (1.2)
maven-plugin                Maven Integration plugin                  2.7.1 (2.12)
ssh-credentials             SSH Credentials Plugin                    1.10 (1.11)
ant                         Ant Plugin                                1.2
credentials                 Credentials Plugin                        1.18 (1.23)
matrix-project              Matrix Project Plugin                     1.4.1 (1.6)
subversion                  Subversion Plug-in                        1.54 (2.5.3)
javadoc                     Javadoc Plugin                            1.1 (1.3)
antisamy-markup-formatter   OWASP Markup Formatter Plugin             1.1 (1.3)
windows-slaves              Windows Slaves Plugin                     1.0 (1.1)
pam-auth                    PAM Authentication plugin                 1.1 (1.2)
postbuildscript             Post-Build Script Plug-in                 0.17
hipchat                     HipChat Plugin                            0.2.0
scm-api                     SCM API Plugin                            0.2
parameterized-trigger       Parameterized Trigger plugin              2.29
jquery                      jQuery plugin                             1.11.2-0
git-client                  GIT client plugin                         1.19.0
swarm                       Self-Organizing Swarm Plug-in Modules     1.22 (2.0)
envinject                   Environment Injector Plugin               1.92.1
purge-build-queue-plugin    Purge Build Queue Plugin                  1.0
greenballs                  Green Balls                               1.14
ansicolor                   AnsiColor                                 0.4.1
git                         GIT plugin                                2.4.0
github-api                  GitHub API Plugin                         1.69
token-macro                 Token Macro Plugin                        1.10
github-oauth                Github Authentication plugin              0.21-SNAPSHOT (private-ae49ebd5-lsstsw) (0.22.2)
collapsing-console-sections Hudson Collapsing Console Sections Plugin 1.4.1
nodelabelparameter          Node and Label parameter plugin           1.5.1
build-user-vars-plugin      user build vars plugin                    1.4
rebuild                     Rebuilder                                 1.25
    EOS
  end

  let(:cli_list_plugins_parsed) do
    [{:name=>"mailer",
      :description=>"Mailer Plugin",
      :version=>"1.11",
      :update_version=>"1.15"},
     {:name=>"script-security",
      :description=>"Script Security Plugin",
      :version=>"1.13",
      :update_version=>"1.15"},
     {:name=>"ldap",
      :description=>"LDAP Plugin",
      :version=>"1.11",
      :update_version=>nil},
     {:name=>"junit",
      :description=>"JUnit Plugin",
      :version=>"1.2-beta-4",
      :update_version=>"1.9"},
     {:name=>"ssh-slaves",
      :description=>"SSH Slaves plugin",
      :version=>"1.9",
      :update_version=>"1.10"},
     {:name=>"cvs",
      :description=>"CVS Plug-in",
      :version=>"2.11",
      :update_version=>"2.12"},
     {:name=>"translation",
      :description=>"Translation Assistance plugin",
      :version=>"1.10",
      :update_version=>"1.12"},
     {:name=>"external-monitor-job",
      :description=>"External Monitor Job Type Plugin",
      :version=>"1.4",
      :update_version=>nil},
     {:name=>"matrix-auth",
      :description=>"Matrix Authorization Strategy Plugin",
      :version=>"1.1",
      :update_version=>"1.2"},
     {:name=>"maven-plugin",
      :description=>"Maven Integration plugin",
      :version=>"2.7.1",
      :update_version=>"2.12"},
     {:name=>"ssh-credentials",
      :description=>"SSH Credentials Plugin",
      :version=>"1.10",
      :update_version=>"1.11"},
     {:name=>"ant",
      :description=>"Ant Plugin",
      :version=>"1.2",
      :update_version=>nil},
     {:name=>"credentials",
      :description=>"Credentials Plugin",
      :version=>"1.18",
      :update_version=>"1.23"},
     {:name=>"matrix-project",
      :description=>"Matrix Project Plugin",
      :version=>"1.4.1",
      :update_version=>"1.6"},
     {:name=>"subversion",
      :description=>"Subversion Plug-in",
      :version=>"1.54",
      :update_version=>"2.5.3"},
     {:name=>"javadoc",
      :description=>"Javadoc Plugin",
      :version=>"1.1",
      :update_version=>"1.3"},
     {:name=>"antisamy-markup-formatter",
      :description=>"OWASP Markup Formatter Plugin",
      :version=>"1.1",
      :update_version=>"1.3"},
     {:name=>"windows-slaves",
      :description=>"Windows Slaves Plugin",
      :version=>"1.0",
      :update_version=>"1.1"},
     {:name=>"pam-auth",
      :description=>"PAM Authentication plugin",
      :version=>"1.1",
      :update_version=>"1.2"},
     {:name=>"postbuildscript",
      :description=>"Post-Build Script Plug-in",
      :version=>"0.17",
      :update_version=>nil},
     {:name=>"hipchat",
      :description=>"HipChat Plugin",
      :version=>"0.2.0",
      :update_version=>nil},
     {:name=>"scm-api",
      :description=>"SCM API Plugin",
      :version=>"0.2",
      :update_version=>nil},
     {:name=>"parameterized-trigger",
      :description=>"Parameterized Trigger plugin",
      :version=>"2.29",
      :update_version=>nil},
     {:name=>"jquery",
      :description=>"jQuery plugin",
      :version=>"1.11.2-0",
      :update_version=>nil},
     {:name=>"git-client",
      :description=>"GIT client plugin",
      :version=>"1.19.0",
      :update_version=>nil},
     {:name=>"swarm",
      :description=>"Self-Organizing Swarm Plug-in Modules",
      :version=>"1.22",
      :update_version=>"2.0"},
     {:name=>"envinject",
      :description=>"Environment Injector Plugin",
      :version=>"1.92.1",
      :update_version=>nil},
     {:name=>"purge-build-queue-plugin",
      :description=>"Purge Build Queue Plugin",
      :version=>"1.0",
      :update_version=>nil},
     {:name=>"greenballs",
      :description=>"Green Balls",
      :version=>"1.14",
      :update_version=>nil},
     {:name=>"ansicolor",
      :description=>"AnsiColor",
      :version=>"0.4.1",
      :update_version=>nil},
     {:name=>"git",
      :description=>"GIT plugin",
      :version=>"2.4.0",
      :update_version=>nil},
     {:name=>"github-api",
      :description=>"GitHub API Plugin",
      :version=>"1.69",
      :update_version=>nil},
     {:name=>"token-macro",
      :description=>"Token Macro Plugin",
      :version=>"1.10",
      :update_version=>nil},
     {:name=>"github-oauth",
      :description=>"Github Authentication plugin",
      :version=>"0.21-SNAPSHOT(private-ae49ebd5-lsstsw)",
      :update_version=>"0.22.2"},
     {:name=>"collapsing-console-sections",
      :description=>"Hudson Collapsing Console Sections Plugin",
      :version=>"1.4.1",
      :update_version=>nil},
     {:name=>"nodelabelparameter",
      :description=>"Node and Label parameter plugin",
      :version=>"1.5.1",
      :update_version=>nil},
     {:name=>"build-user-vars-plugin",
      :description=>"user build vars plugin",
      :version=>"1.4",
      :update_version=>nil},
     {:name=>"rebuild",
      :description=>"Rebuilder",
      :version=>"1.25",
      :update_version=>nil}]
  end

  shared_examples "a provider from example hash 1" do
    it do
      expect(provider.name).to eq cli_list_plugins_parsed[0][:name]
      expect(provider.ensure).to eq :present
      expect(provider.description).to eq cli_list_plugins_parsed[0][:description]
      expect(provider.version).to eq cli_list_plugins_parsed[0][:version]
      expect(provider.update_version).to eq cli_list_plugins_parsed[0][:update_version]
    end
  end

  shared_examples "a provider from example hash 34" do
    it do
      expect(provider.name).to eq cli_list_plugins_parsed[34][:name]
      expect(provider.ensure).to eq :present
      expect(provider.description).to eq cli_list_plugins_parsed[34][:description]
      expect(provider.version).to eq cli_list_plugins_parsed[34][:version]
      #expect(provider.update_version).to eq cli_list_plugins_parsed[34][:update_version]
      expect(provider.update_version).to eq :undef
    end
  end

  include_examples 'confines to cli dependencies'

  describe "::instances" do
    context "without any params" do
      before do
        expect(described_class).to receive(:list_plugins).
          with(nil) { cli_list_plugins_parsed }
      end

      it "should return the correct number of instances" do
        expect(described_class.instances.size).to eq 38
      end

      context "first instance returned" do
        it_behaves_like "a provider from example hash 1" do
          let(:provider) do
            described_class.instances[0]
          end
        end
      end

      context "second instance returned" do
        it_behaves_like "a provider from example hash 34" do
          let(:provider) do
            described_class.instances[34]
          end
        end
      end
    end

    context "when called with a catalog param" do
      it "should pass it on ::list_plugins" do
        catalog = Puppet::Resource::Catalog.new

        expect(described_class).to receive(:list_plugins).
          with(catalog) { cli_list_plugins_parsed }

        described_class.instances(catalog)
      end
    end
  end # ::instanes

  # read only properties
  [:description=, :version=, :update_version=].each do |prop|
    describe "##{prop}" do
      it 'should be read only (fail)' do
        provider = described_class.new

        expect { provider.send(prop, 'foo') }.
          to raise_error(Puppet::Error, /is read-only/)
      end
    end
  end

  describe '#flush' do
    it 'should call user_update' do
      provider = described_class.new
      provider.create

      expect(provider).to receive(:install_plugin)
      provider.flush
    end

    it 'should call delete_user' do
      provider = described_class.new
      provider.destroy

      expect { provider.flush }.
        to raise_error(Puppet::Error, /invalid :ensure value: absent/)
    end
  end # #flush

  #
  # private methods
  #

  describe '::from_hash' do
    it_behaves_like "a provider from example hash 1" do
      let(:provider) do
        described_class.send :from_hash, cli_list_plugins_parsed[0]
      end
    end

    it_behaves_like "a provider from example hash 34" do
      let(:provider) do
        described_class.send :from_hash, cli_list_plugins_parsed[34]
      end
    end
  end # ::from_hash

  describe '::list_plugins' do
    it do
      expect(described_class).to receive(:cli).with(
        ['list-plugins'],
        { :catalog => nil},
      ) { cli_list_plugins_output }

      plugins = described_class.send :list_plugins
      expect(plugins).to eq cli_list_plugins_parsed
    end
  end # ::list_plugins

  describe '#install_plugin' do
    it do
      provider = described_class.send :from_hash, cli_list_plugins_parsed[0]

      expect(described_class).to receive(:cli).with(
        ['install-plugin', 'mailer'],
      )

      provider.send :install_plugin
    end

    it 'should use -name flag when name and source do not match' do
      provider = described_class.new(
        :name        => 'bogo',
        :description => 'bogo description',
        :source      => 'http://example.org/bogo'
      )

      expect(described_class).to receive(:cli).with([
        'install-plugin', 'http://example.org/bogo',
        '-name', 'bogo',
      ])

      provider.send :install_plugin
    end

    it 'shold use -deploy flag when deploy is true' do
      provider = described_class.new(
        :name   => 'bogo',
        :deploy => true,
      )

      expect(described_class).to receive(:cli).with([
        'install-plugin', 'bogo',
        '-deploy'
      ])

      provider.send :install_plugin
    end

    it 'shold use -restart flag when restart is true' do
      provider = described_class.new(
        :name    => 'bogo',
        :restart => true,
      )

      expect(described_class).to receive(:cli).with([
        'install-plugin', 'bogo',
        '-restart'
      ])

      provider.send :install_plugin
    end
  end # #install_plugin
end
