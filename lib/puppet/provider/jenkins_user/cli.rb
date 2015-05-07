require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_user).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    all = nil
    unless catalog.nil?
      all = user_info_all(catalog)
    else
      all = user_info_all
    end

    Puppet.debug("#{sname} instances: #{all.collect {|i| i['id']}}")

    all.collect {|info| from_hash(info) }
  end

  def api_token_public=(value)
    fail "api_token_pubilc is read-only"
  end

  def flush
    boost = resource.nil? ? self.ensure : resource[:ensure]
    case boost
    when :present
      user_update
    when :absent
      delete_user
    else
      fail("invalid :ensure value: #{boost}")
    end
  end

  private

  def self.from_hash(info)
    # map nil -> :undef
    info = PuppetX::Jenkins::Util.undefize(info)

    new({
      :name             => info['id'],
      :ensure           => :present,
      :full_name        => info['full_name'],
      :email_address    => info['email_address'],
      :api_token_plain  => info['api_token_plain'],
      :api_token_public => info['api_token_public'],
      :public_keys      => info['public_keys'],
      :password         => info['password'],
    })
  end
  private_class_method :from_hash

  def to_hash
    info = { 'id' => name }

    properties = self.class.resource_type.validproperties
    properties.reject! {|x| x == :ensure }
    properties.reject! {|x| x == :api_token_public}

    properties.each do |prop|
      value = resource.nil? ? public_send(prop) : resource[prop]
      if value != :absent
        info[prop.to_s] = value
      end
    end

    # map :undef -> nil
    PuppetX::Jenkins::Util.unundef(info)
  end

  # array of hashes for multiple users
  def self.user_info_all(catalog = nil)
    raw = nil
    unless catalog.nil?
      raw = clihelper(['user_info_all'], :catalog => catalog)
    else
      raw = clihelper(['user_info_all'])
    end

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      fail("unable to parse as JSON: #{raw}")
    end
  end
  private_class_method :user_info_all

  def user_update
    input ||= to_hash

    clihelper(['user_update'], :stdinjson => input)
  end

  def delete_user
    clihelper(['delete_user', name])
  end
end
