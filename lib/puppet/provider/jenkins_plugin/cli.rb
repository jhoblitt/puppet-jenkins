require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_plugin).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    #all = list_plugins(catalog)
    all = installed_plugin_info(catalog)

    Puppet.debug("#{all.class}")
    Puppet.debug("#{all.size}")
    Puppet.debug("#{sname} instances: #{all.keys}")

    all.collect {|name, info| from_hash(info) }
  end

  # read-only properties
  [:description=, :version=, :update_version=].each do |prop|
    define_method(prop) { |x| fail "#{prop} is read-only" }
  end

  def flush
    unless resource.nil?
      [:ensure, :source, :deploy, :restart].each do |attr|
        @property_hash[attr] = resource[attr]
      end
    end

    case @property_hash[:ensure]
    when :present
      install_plugin
    else
      fail("invalid :ensure value: #{@property_hash[:ensure]}")
    end
  end

  private

  #def self.from_hash(info)
  #  # map nil -> :undef
  #  info = PuppetX::Jenkins::Util.undefize(info)

  #  new({
  #    :name             => info[:name],
  #    :ensure           => :present,
  #    :description      => info[:description],
  #    :version          => info[:version],
  #    :update_version   => info[:update_version],
  #  })
  #end

  def self.from_hash(info)
    # map nil -> :undef
    info = PuppetX::Jenkins::Util.undefize(info)

    update_version = nil
    if info.has_key?('updateInfo')
      update_version = info['updateInfo']['version']
    end
    new({
      :name           => info['shortName'],
      :ensure         => :present,
      :description    => info['longName'],
      :version        => info['version'],
      :update_version => update_version,
    })
  end
  private_class_method :from_hash

  def self.list_plugins(catalog = nil)
    raw = cli(['list-plugins'], :catalog => catalog)

    raw.split("\n").collect do |line|
      # the cli uses left justified fixed width fields for out starting at col 1,
      # 29, & 71
      fields = line.unpack('A28A42A*').collect {|col| col.strip}
      plugin = Hash[[:name, :description, :version].zip(fields)]

      # generally, if avaiable, the version has an update version in parens
      # 1.13 (1.15)
      # there appears to be a special case when the plugin was built from source
      # 0.21-SNAPSHOT (private-ae49ebd5-lsstsw) (0.22.2) which prevents us from
      # splitting on a space between the two version specififications
      version, *extras = plugin[:version].split
      if extras.size > 1
        version += extras.delete_at 0
      end
      plugin[:version] = version
      # strip surounding parens
      plugin[:update_version] = extras[0].nil? ? nil : extras[0].gsub(/[()]/, '')
      plugin
    end
  end
  private_class_method :list_plugins

  def self.installed_plugin_info(catalog = nil)
    raw = clihelper(['installed_plugin_info'], :catalog => catalog)

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      fail("unable to parse as JSON: #{raw}")
    end
  end
  private_class_method :installed_plugin_info

  def install_plugin
    def absent_to_false(x)
      return false if x == :absent
      x
    end

    args = ['install-plugin']

    # if source is absent, use the name as source
    unless absent_to_false(source)
      args << name
    else
      args << source
      # if source is defined, and it matches the name, omit the -name arg
      args << '-name' << name unless source == name
    end

    args << '-deploy' if absent_to_false(deploy)
    args << '-restart' if absent_to_false(restart)

    cli(args)
  end
end
