require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_plugin) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end #ensure

    describe 'deploy' do
      it 'does not allow non-boolean values' do
        expect {
          described_class.new(
            :name   => 'foo',
            :ensure => :present,
            :deploy => 'unknown')
          }.to raise_error Puppet::ResourceError, /Valid values are true, false, yes, no/
      end
    end

    describe 'restart' do
      it 'does not allow non-boolean values' do
        expect {
          described_class.new(
            :name    => 'foo',
            :ensure  => :present,
            :restart => 'unknown')
          }.to raise_error Puppet::ResourceError, /Valid values are true, false, yes, no/
      end
    end

    # unvalidated params
    describe 'source' do
      it { expect(described_class.attrtype(:source)).to eq :param}
      it 'should default to name' do
        resource = described_class.new(:name => 'foo')
        expect(resource[:source]).to eq 'foo'
      end
    end
  end #parameters

  describe 'properties' do
    describe 'ensure' do
      context 'attrtype' do
        it { expect(described_class.attrtype(:ensure)).to eq :property }
      end

      context 'class' do
        it do
          expect(described_class.propertybyname(:ensure).ancestors).
            to include(Puppet::Property::Ensure)
        end
      end

      it "should have no default value" do
        user = described_class.new(:name => "nobody")
        expect(user.should(:ensure)).to be_nil
      end

      [:present].each do |value|
        it "should support #{value} as a value to :ensure" do
          expect { described_class.new(:name => "nobody", :ensure => value) }.
            to_not raise_error
        end
      end

      it "should reject unknown values" do
        expect { described_class.new(:name => "nobody", :ensure => :foo) }.
          to raise_error(Puppet::Error)
      end
    end # ensure

    # read-only properties
    [:description, :version, :update_version].each do |prop|
      describe "#{prop}" do
        it { expect(described_class.attrtype(prop)).to eq :property }
        it do
          expect { described_class.new(:name => "nobody", prop => :foo) }.
            to raise_error(Puppet::ResourceError, /#{prop} property is read-only/)
        end
      end
    end
  end #properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'
  end
end
