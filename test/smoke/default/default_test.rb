# # encoding: utf-8

# Inspec test for recipe spec_test::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

#unless os.windows? && os.ubuntu?
  # This is an example test, replace with your own test.
#  describe user('root'), :skip do
#    it { should exist }
#  end
#end

# This is an example test, replace it with your own test.
#describe port(80), :skip do
#  it { should_not be_listening }
#end
%w(/var/chef /var/chef/cache /var/chef/cache/blade_logic_client).each do |dir_name|
	describe file("#{dir_name}") do
		its('type') { should eq :directory }
		it { should be_directory }
	end
end

describe file('/var/chef/cache/blade_logic_client/RSCD86-SP1-LIN64.rpm') do
	its('type') { should eq :file }
	it { should be_file }
end

describe file('/usr/lib/rsc/users.local') do
	its('type') { should eq :file }
	it { should be_file }
end

	
describe package('rscd') do
  it { should be_installed }
#  its('version') { should eq '1.9.5' }
end


describe service('rscd') do
  it { should be_running }
  # it { should be_monitored.by("monit") }
end
