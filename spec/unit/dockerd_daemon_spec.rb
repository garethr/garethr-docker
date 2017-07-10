require 'spec_helper'

describe 'dockerd_binary fact' do

  before :each do
    Facter.clear
  end

  context 'when the dockerd binary is NOT present' do

    before :each do
      Facter.fact(:dockerd_binary).stubs(:value).returns(nil)
    end

    it 'return nil' do
      expect(Facter.fact(:dockerd_binary).value).to be_nil
    end
  end

  context 'when the dockerd binary is installed' do

    before :each do
      Facter.fact(:dockerd_binary).stubs(:value).returns('/some/path/to/dockerd')
    end

    it 'return the full path to the dockerd binary' do
      expect(Facter.fact(:dockerd_binary).value).to eq('/some/path/to/dockerd')
    end
  end
end
