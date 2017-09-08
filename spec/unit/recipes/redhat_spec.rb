#
# Cookbook:: spec_test
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'blade_logic::redhat' do
  context 'Validate supported installations' do
    before do
     stub_data_bag_item('artifacts', 'blade_logic').and_return(
#       'blade_logic' =>  {
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
#        }
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
      expect(chef_run).to create_remote_file("/var/chef/cache/blade_logic_client/RSCD86-SP1-LIN64.rpm").with(owner: 'root',group: 'root',mode: '0750' )
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
	
	it 'returns an error when datacenter attribute is not set' do
      node.normal['aig']['datacenter'] = nil 
     expect { chef_run }.to raise_error(ArgumentError, 'The chosen location is not supported or the blade_logic binary information not found.')
    end
	
	 it 'creates a directory with attributes' do
    %w(/var/chef /var/chef/cache /var/chef/cache/blade_logic_client).each do |dir_name|
	 expect(chef_run).to create_directory("#{dir_name}").with(
      user:   'root',
      group:  'root',
	  mode: '0755'
    )
	end
	end
	#it 'returns an error when chosen location is not found' do
     #node.normal['aig']['datacenter'] = 'bad_location'
     #expect { chef_run }.to raise_error(ArgumentError, 'The chosen location is not supported or the blade_logic binary information not found.')
    #end

    it 'returns an error when data_bag (\'artifacts\',\'blade_logic\') is not found' do
     stub_data_bag_item('artifacts', 'blade_logic').and_return(nil)
     expect { chef_run }.to raise_error(ArgumentError, 'Unable to locate the DataBagItem("artifacts","blade_logic")')
    end

    
	
end
end
end
  context 'Validate unsupported platforms' do
    platforms = {
      'windows' => {
        'versions' => %w(2012 2012r2)
      },
	  'ubuntu' => {
         'versions' => %w(14.04 16.04)
	  }
    }
    platforms.each do |platform, components|
      components['versions'].each do |version|
        context "On #{platform} #{version}" do
          context 'When all attributes are default' do
            before do
              Fauxhai.mock(platform: platform, version: version)
            end
            let(:chef_run) do
              ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
                # Node attributes
              end.converge(described_recipe)
            end

            it 'raises an exception' do
              expect { chef_run }.to raise_error(ArgumentError, "ERROR: Unsupported Operating system #{platform}. Please run this cookbook on RHEL systems only!!!")
            end
          end

end
end
end
end

end