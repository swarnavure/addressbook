from tomcat:8.5.72-jdk17-openjdk-buster
add /var/lib/jenkins/workspace/package/target /usr/local/tomcat/webapps
expose 8080
cmd ["catalina.sh", "run"]
 
