

raise ArgumentError,"ERROR: Unsupported Operating system #{node['platform'] }. Please run this cookbook on RHEL systems only!!!" if node['platform_family'] != 'rhel'

begin
  blade_logic_artifact = data_bag_item('artifacts', 'blade_logic')
  raise if blade_logic_artifact.nil?
rescue
  blade_logic_artifact = {} 
 raise ArgumentError, "Unable to locate the DataBagItem(\"artifacts\",\"blade_logic\")"
end


dc_pref = node['aig']['datacenter']
raise ArgumentError, 'The chosen location is not supported or the binary information not found.' if blade_logic_artifact[dc_pref].nil? || dc_pref.nil?


dc_pref_child_key = blade_logic_artifact[dc_pref]
raise ArgumentError, 'The chosen location does not appear to have a supported binary path and was not found.' if dc_pref_child_key[package].nil?

binary_name = (dc_pref_child_key['package']).split('/')[-1]

remote_file "/var/chef/cache/blade_logic_client/#{binary_name}" do
  source dc_pref_child_key['package']
  checksum dc_pref_child_key['checksum']
  owner 'root'
  group 'root'
  mode '0750'
  action :create
end

package 'Install rscd' do
  package_name  "::File.basename(#{binary_name}, '.*')"             
  source "/var/chef/cache/blade_logic_client/#{binary_name}"
  action :install
end

service "rscd" do
    action :start
end

template '/usr/lib/rsc/users.local' do
  source 'users.local.erb'
  owner 'root'
  group 'root'
  mode '0644'
end





