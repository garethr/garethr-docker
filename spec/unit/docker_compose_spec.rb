require 'spec_helper'

compose = Puppet::Type.type(:docker_compose)

describe compose do

  let :params do
    [
      :name,
      :provider,
      :scale,
      :options,
    ]
  end

  let :properties do
    [
      :ensure,
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(compose.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(compose.parameters).to be_include(param)
    end
  end

	it 'should require options to be a string' do
		expect(compose).to require_string_for('options')
  end

	it 'should require scale to be a hash' do
		expect(compose).to require_hash_for('scale')
  end
end
