require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_num_executors).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    n = get_num_executors(catalog)

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
      set_num_executors
    else
      fail("invalid :ensure value: #{boost}")
    end
  end

  private

  def self.get_num_executors(catalog = nil)
    clihelper(['get_num_executors'], :catalog => catalog).to_i
  end
  private_class_method :get_num_executors

  def set_num_executors(n = nil)
    n ||= name
    clihelper(['set_num_executors', n])
  end
end
