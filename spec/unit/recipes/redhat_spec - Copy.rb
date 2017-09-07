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
          context 'When all attributes are default' do
            before do
              Fauxhai.mock(platform: platform, version: version)
              # Node attributes
              node.normal['aig']['datacenter'] = 'am1'
			  blade_logic_artifact = stub_data_bag_item('artifacts', 'blade_logic')
			  dc_pref = node['aig']['datacenter']
              dc_pref_child_key = stub_data_bag_item('blade_logic_artifact', 'dc_pref')
              binary_name = stub_data_bag_item('dc_pref_child_key', 'package')
#              binary_name = stub_data_bag_item('dc_pref_child_key', 'package').split('/')[-1]

            end
            let(:runner) do
              ChefSpec::SoloRunner.new(platform: platform, version: version)
            end
            let(:node) { runner.node }
            let(:chef_run) { runner.converge(described_recipe) }

            it 'converges successfully' do
                 expect { chef_run }.to_not raise_error
              %w(/var /var/chef /var/chef/cache /var/chef/cache/blade_logic_client).each do |dir_name|
                 expect(chef_run).to create_directory(dir_name).with(owner: 'root', group: 'root', mode: '0755')
             end
			    expect(chef_run).to create_remote_file("/var/chef/cache/blade_logic_client/#{binary_name}").with(source: stub_data_bag_item('dc_pref_child_key', 'package'))
                expect(chef_run).to install_package("::File.basename(#{binary_name}, '.*')" ).with(source: "/var/chef/cache/blade_logic_client/#{binary_name}")
                expect(chef_run).to create_template('/usr/lib/rsc/users.local').with( user: 'root', group: 'root', mode: '0644' )

            end

            
        end
      end
    end
  end
  
end
end