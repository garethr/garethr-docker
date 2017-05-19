require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  describe 'docker_info' do
    context 'with docker installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:which).with('docker') { true }
        expect(Facter::Util::Resolution).to receive(:exec).with('docker info --format "{{json .}}" 2>&1') {
          '{"ServerVersion": "1.13.1"}'
				}
      end
      it do
        expect(Facter.fact(:docker_info).value).to have_key( "ServerVersion" )
      end
    end
    context 'no docker installed' do
      before :each do
        expect(Facter::Util::Resolution).to receive(:which).with('docker') { false }
      end
      it do
        expect(Facter.fact(:docker_info).value).to be_nil
      end
    end
  end

end

