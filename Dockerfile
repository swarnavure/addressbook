from tomcat:8.5.72-jdk17-openjdk-buster
copy /var/lib/jenkins/workspace/package/target /usr/local/tomcat/webapps
EXPOSE 8080
CMD ["catalina.sh", "run"]

