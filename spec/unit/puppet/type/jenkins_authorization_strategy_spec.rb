require 'spec_helper'
require 'unit/puppet_x/spec_jenkins_types'

describe Puppet::Type.type(:jenkins_authorization_strategy) do
  before(:each) { Facter.clear }

  describe "parameters" do
    describe "name" do
      it_behaves_like 'generic namevar', :name
    end # name
  end # parameters

  describe "properties" do
    describe "ensure" do
      it_behaves_like 'generic ensurable'
    end # ensure

    describe "arguments" do
      context 'attrtype' do
        it { expect(described_class.attrtype(:arguments)).to eq :property }
      end

      context 'array_matching' do
        it do
          expect(described_class.attrclass(:arguments).array_matching).to eq :all
        end
      end

      it "should support an array of mixed types" do
        value = [true, "foo"]
        resource = described_class.new(:name => "test", :arguments => value)
        expect(resource[:arguments]).to eq value
      end
    end # arguments
  end # properties

  describe 'autorequire' do
    it_behaves_like 'autorequires cli resources'
    it_behaves_like 'autorequires all jenkins_user resources'
    it_behaves_like 'autorequires jenkins_security_realm resource'
  end
end
