require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_slaveagent_port).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    n = get_slaveagent_port(catalog)

    # there can be only one value
    Puppet.debug("#{sname} instances: #{n}")

    args = {
      :name => n,
      :ensure => :present,
    }

    [new(args)]
  end

  def flush
    boost = resource.nil? ? self.ensure : resource[:ensure]
    case boost
    when :present
      set_slaveagent_port
    else
      fail("invalid :ensure value: #{boost}")
    end
  end

  private

  def self.get_slaveagent_port(catalog = nil)
    clihelper(['get_slaveagent_port'], :catalog => catalog).to_i
  end
  private_class_method :get_slaveagent_port

  def set_slaveagent_port(n = nil)
    n ||= name
    clihelper(['set_slaveagent_port', n])
  end
end
