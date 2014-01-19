require 'spec_helper_system'

describe 'docker class' do

  context 'default parameters' do 

    it 'should install without errors' do
      pp = <<-EOS
        class { 'docker': }
      EOS

      puppet_apply(pp) do |run|
        run.exit_code.should == 2
        run.refresh
        run.exit_code.should be_zero
      end
    end

    describe service('docker') do
      it { should be_enabled }
      it { should be_running }
    end

    describe command('sudo docker version') do
      it { should return_exit_status 0 }
      it { should return_stdout(/0\.7\./) }
    end

  end
end
