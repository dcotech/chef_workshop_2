tomcat_install 'tomcat' do
  version '8.0.36'
end

tomcat_service 'tomcat' do
  action [:start, :enable]
  env_vars [{ 'CATALINA_PID' => '/opt/tomcat/tomcat_tomcat/tomcat.pid' }]
end
