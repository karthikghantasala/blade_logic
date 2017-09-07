#
# Cookbook:: blade_logic
# Spec:: redhat
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'


describe 'blace_logic::redhat' do
  context 'Validate supported installations' do
    before do
     stub_data_bag_item('artifacts', 'blade_logic').and_return(
        {
    		'am1' => {
             'package' => 'https://am1.artifactory/RSCD86-SP1-LIN64.rpm',
             'checksum' => '<shasum256>',
			 'version' => '8.6SP1'
            },
           'aws_us_east_1' => {
             'package' => 'https://locb.customeralpha.org/appbincustom.rpm',
             'checksum' => '<shasum256>',
			 'version' => '8.6SP1'
            }
        }
      )
    end
  platforms = {
       'redhat' => {
         'versions' => %w(6.6 7.3)
      }
    }
    platforms.each do |platform, components|
      components['versions'].each do |version|
        context "On #{platform} #{version}" do
    
#  context 'When all attributes are default, on an rhel 6.6, 7.3' do
#    let(:chef_run) do
#      # for a complete list of available platforms and versions see:
#      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
#      runner = ChefSpec::ServerRunner.new(platform: platform, version: version)
#      runner.converge(described_recipe)
    end
    before do
              Fauxhai.mock(platform: platform, version: version)
              # Node attributes
              node.normal['aig']['datacenter'] = 'am1'
            end
            let(:runner) do
              ChefSpec::SoloRunner.new(platform: platform, version: version)
            end
            let(:node) { runner.node }
            let(:chef_run) { runner.converge(described_recipe) }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
	end
	
	it 'creates a remote_file with attributes' do
      expect(chef_run).to create_remote_file("/var/chef/cache/blade_logic_client/data_bag_item[").with(owner: 'root',group: 'root',mode: '0750' )
    end
	
	it 'installs a package when specifying the identity attribute' do
      expect(chef_run).to install_package('rscd')
    end
	
	it 'creates a template with attributes' do
      expect(chef_run).to create_template('/usr/lib/rsc/users.local').with(source: 'users.local.erb', owner: 'root',group: 'root',mode: '0644' )
	end
	
	it 'enables a service with an explicit action' do
     expect(chef_run).to enable_service('rscd')
    end
	
end
end
end
end
#end
