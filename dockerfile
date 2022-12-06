from tomcat:8.5.72-jdk17-openjdk-buster
copy /var/lib/jenkins/workspace/package/target /usr/local/tomcat
expose 8080
cmd ["catalina.sh","run"]
 
