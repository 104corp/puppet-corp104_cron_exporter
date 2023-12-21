require 'spec_helper'

describe 'corp104_cron_exporter', :type => 'class' do
  context 'with defaults for all parameters' do
    let(:facts) do
      { 
        :os => { :family => 'Debian', :name => 'Ubuntu', :release => { :major => '16.04', :full => '16.04' }},
        :lsbdistrelease   => '16.04',
        :lsbdistid        => 'Ubuntu',
        :osfamily         => 'Debian',
        :lsbdistcodename  => 'xenial',
        :service_provider => 'systemd',
      }
    end
    it do
      should contain_class('corp104_cron_exporter')
      should contain_class('corp104_cron_exporter::install')
      should contain_class('corp104_cron_exporter::service')
    end

    it do
      should compile.with_all_deps
    end

  end
end
