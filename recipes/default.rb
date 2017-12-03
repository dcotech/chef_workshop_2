#
# Cookbook:: lcd_tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
package ['java-1.7.0-openjdk-devel','wget'] do
end

user 'tomcat' do
  comment 'Tomcat user'
  home '/opt/tomcat'
  shell '/bin/nologin'
end

group 'tomcat' do
  members 'tomcat'
  append true
end

cookbook_file '/tmp/apache-tomcat-8.5.24.tar.gz' do
  source 'apache-tomcat-8.5.24.tar.gz'
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
end

bash 'download and extract' do
  code <<-EOH
  cd /tmp
  mkdir -p /opt/tomcat
  sudo tar -zxvf /tmp/apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
  EOH
  not_if { ::File.exist?('/opt/tomcat/conf') }
end

bash 'update permissions' do
  code <<-EOH
    sudo chgrp -R tomcat /opt/tomcat
    cd /opt/tomcat
    sudo chmod -R g+r conf
    sudo chmod g+x conf
    sudo chown -R tomcat webapps/ work/ temp/ logs/
  EOH
  not_if { ::File.exist?('/etc/systemd/system/tomcat.service') }
end

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action
end

service 'tomcat' do
 action [:enable, :start]
 subscribes :reload,'template[/etc/systemd/systemd/tomcat.service]', :immediately
end
