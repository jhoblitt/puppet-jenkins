require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_job) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end #name
  end #parameters

  describe 'properties' do
    describe 'ensure' do
      it_behaves_like 'generic ensurable'
    end #ensure

    describe 'enable' do
      it { expect(described_class.attrtype(:enable)).to eq :property }

      it 'does not allow non-boolean values' do
        expect {
          described_class.new(:name => 'foo', :enable => 'unknown')
        }.to raise_error Puppet::ResourceError, /expected a boolean value/
      end

      it 'should default to true' do
        resource = described_class.new(:name => 'nobody', :ensure => :present)
        expect(resource.should(:enable)).to eq true
      end

    end

    # unvalidated properties
    [:config].each do |property|
      describe "#{property}" do
        it { expect(described_class.attrtype(property)).to eq :property }
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
