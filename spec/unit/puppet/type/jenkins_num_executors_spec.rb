require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_num_executors) do
  before(:each) { Facter.clear }

  describe 'parameters' do
    describe 'name' do
      it_behaves_like 'generic namevar', :name
    end #name
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
  end # properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
    it_behaves_like 'autorequires jenkins_authorization_strategy resource'
  end
end
