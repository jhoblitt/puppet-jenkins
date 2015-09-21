require 'puppet/parameter/boolean'

require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_plugin) do
  @doc = 'Manage Jenkins\' plugins'

  # the cli jar does not have an interface for plugin removal so the only
  # allowed ensure value is :present
  ensurable do
    newvalue(:present) { provider.create }
  end

  newparam(:name) do
    desc 'plugin name - E.g. "github"'
    isnamevar
  end

  # read-only properties
  [:description, :version, :update_version].each do |prop|
    newproperty(prop) do
      desc 'property is read-only.'
      validate do |value|
        raise ArgumentError, "#{prop} property is read-only"
      end
    end
  end

  newparam(:source) do
    desc 'If this points to a local file, that file will be installed. If this
is an URL, Jenkins downloads the URL and installs that as a plugin.Otherwise
the name is assumed to be the short name of the plugin in the existing update
center (like "findbugs"),and the plugin will be installed from the update
center'
    defaultto { @resource[:name] }
  end

  newparam(:deploy, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Deploy plugins right away without postponing them until the reboot.'
    defaultto true
  end

  newparam(:restart, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Restart Jenkins upon successful installation'
    defaultto false
  end

  # require all authentication & authorization related types
  [
    :jenkins_user,
    :jenkins_security_realm,
    :jenkins_authorization_strategy,
  ].each do |type|
    autorequire(type) do
      catalog.resources.find_all do |r|
       r.is_a?(Puppet::Type.type(type))
      end
    end
  end
end # Puppet::Type
