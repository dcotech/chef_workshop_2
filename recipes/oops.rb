#
# Cookbook:: lcd_tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
package 'java-1.7.0-openjdk-devel' do
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

remote_file '/tmp/apache-tomcat-8.5.20.tar.gz' do
  source 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9-deployer.tar.gz'
  mode '0755'
  show_progress true
  action :create
end

bash 'extract_module' do
  code <<-EOH
    mkdir -p /opt/tomcat
    tar xzf /tmp/apache-tomcat-8.5.20.tar.gz -C /opt/tomcat
    mv /opt/tomcat/*/* /opt/tomcat
    EOH
  #not_if { ::File.exist?(extract_path) }
end

bash 'make directories' do
   code <<-EOH
     mkdir /opt/tomcat/conf
     mkdir /opt/tomcat/webapps
     mkdir /opt/tomcat/work
     mkdir /opt/tomcat/temp
     mkdir /opt/tomcat/logs
     EOH

end

bash 'update permissions' do
  code <<-EOH
    sudo chgrp -R tomcat /opt/tomcat
    sudo chmod -R g+r /opt/tomcat/conf
    sudo chmod g+x /opt/tomcat/conf
    cd /opt/tomcat
    sudo chown -R tomcat webapps/ work/ temp/ logs/
    EOH
end

bash 'SystemD controls: installs unit file and reloads service' do
  code <<-EOH
    sudo vi /etc/systemd/system/tomcat.service
    sudo systemctl daemon-reload
    sudo systemctl start tomcat
    sudo systemctl enable tomcat
    EOH
end
