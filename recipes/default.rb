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
  action [:create, :modify]
  members 'tomcat'
  append true
end

remote_file '/tmp/apache-tomcat-8.5.23.tar.gz' do
  source 'http://apache.mirrors.pair.com/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz'
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
end

systemd_unit 'tomcat.service' do
  content({
     Unit: {
       Description: 'Apache Tomcat Web Application Container',
       After: 'network.target',
     },
     Service: {
       Type: 'forking',
       ExecStart: '/usr/local/etcd',
       Environment: 'JAVA_HOME=/usr/lib/jvm/jre',
       Environment: 'CATALINA_PID=/opt/tomcat/temp/tomcat.pid',
       Environment: 'CATALINA_HOME=/opt/tomcat',
       Environment: 'CATALINA_BASE=/opt/tomcat',
       Environment: 'CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC',
       Environment: 'JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom',

       ExecStart: '/opt/tomcat/bin/startup.sh',
       ExecStop: '/bin/kill -15 $MAINPID',

       User: 'tomcat',
       Group: 'tomcat',
       Umask: '0007',
       RestartSec: '10',
       Restart: 'always',
     },
     Install: {
       WantedBy: 'multi-user.target',
     },
   })
  action :create
end

service 'tomcat' do
 action [:enable, :start]
 subscribes :reload,'systemd_unit[tomcat.service]', :immediately
end
