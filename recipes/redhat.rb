#
# Cookbook:: blade_logic
# Recipe:: redhat
#
# Copyright:: 2017, The Authors, All Rights Reserved.


raise ArgumentError,"ERROR: Unsupported Operating system #{node['platform'] }. Please run this cookbook on RHEL systems only!!!" if node['platform_family'] != 'rhel'

#blade_logic_artifact = data_bag_item('artifacts', 'blade_logic')
begin
  blade_logic_artifact = data_bag_item('artifacts', 'blade_logic')
  raise if blade_logic_artifact.nil?
rescue
  blade_logic_artifact = {} 
  raise ArgumentError, 'Unable to locate the DataBagItem("artifacts","blade_logic")'
end

dc_pref = node['aig']['datacenter']
raise ArgumentError, 'The chosen location is not supported or the blade_logic binary information not found.' if dc_pref.nil? 

#data_bag_item( 'artifacts', 'blade_logic' ).each do |dc_code|
#raise ArgumentError, 'The chosen location is not supported or the blade_logic binary information not found.' if dc_pref != dc_code 
#end


#dc_pref_child_key = blade_logic_artifact['dc_pref']
#binary_name = dc_pref_child_key['package']
#binary_name = blade_logic_artifact['dc_pref']['package']
binary_name = (blade_logic_artifact[node['aig']['datacenter']]['package']).split('/')[-1]

remote_file "/var/chef/cache/blade_logic_client/#{binary_name}" do
  source "https://am1.artifactory/#{binary_name}"
  checksum 'checksum'
  owner 'root'
  group 'root'
  mode '0750'
  action :create
end

package 'Install rscd' do
  package_name  'rscd'             
  source "/var/chef/cache/blade_logic_client/#{binary_name}"
  action :install
end


template '/usr/lib/rsc/users.local' do
  source 'users.local.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

service "rscd" do
    action :enable
end