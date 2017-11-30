# # encoding: utf-8

# Inspec test for recipe lcd_tomcat::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end

describe package('java-1.7.0-openjdk-devel') do
  it { should be_installed }
end

describe service('tomcat') do
  it { should be_enabled }
  it { should be_running }
end

describe port('8080'), :skip do
  it { should be_listening }
end

describe port('8443'), :skip do
  it { should be_listening }
end

describe port('8009'), :skip do
  it { should be_listening }
end

describe group('tomcat') do
  it { should exist }
end

describe user('tomcat') do
  it { should exist}
  its('group') { should eq 'tomcat'}
  its('shell') { should eq '/bin/nologin'}
  its('home') { should eq '/opt/tomcat' }
end

