#
# Cookbook:: lcd_tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
package 'java-1.7.0-openjdk-devel' do
end

package 'wget' do
end

user 'tomcat' do
  comment 'Tomcat user'
  home '/opt/tomcat'
  shell '/bin/nologin'
end

group 'tomcat' do
  action [:create, :modify]
  members 'tomcat'
  append true
end

bash 'download' do
  code <<-EOH
  cd /tmp
  sudo wget http://apache.mirrors.pair.com/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz
  EOH
end

bash 'extract_module' do
  code <<-EOH
    mkdir -p /opt/tomcat
    sudo tar -zxvf /tmp/apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
    EOH
  #not_if { ::File.exist?(extract_path) }
end


bash 'update permissions' do
  code <<-EOH
    sudo chgrp -R tomcat /opt/tomcat
    cd /opt/tomcat
    sudo chmod -R g+r conf
    sudo chmod g+x conf
    sudo chown -R tomcat webapps/ work/ temp/ logs/
    EOH
end

cookbook_file '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service'
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
  action :create
end

bash 'SystemD controls: installs unit file and reloads service' do
  code <<-EOH
    sudo systemctl daemon-reload
    sudo systemctl start tomcat
    sudo systemctl enable tomcat
    EOH
end
