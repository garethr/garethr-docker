require 'spec_helper_system'

describe 'docker' do
  it 'class should install without errors' do
    pp = <<-EOS
      class { 'docker': }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
      r.refresh
      r.exit_code.should be_zero
    end

    shell('docker version') do |r|
      r.exit_code.should be_zero
      r.stderr.should be_empty
    end
  end
end
