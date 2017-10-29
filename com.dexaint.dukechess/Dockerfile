# Install CentOS
FROM centos:centos7
MAINTAINER Junbin "zjbthomas@gmail.com"

# Install necessary components
RUN yum -y install git
RUN yum -y install wget

# Clone form DukeChess
RUN git clone https://github.com/zjbthomas/DukeChess.git

# Install JDK
RUN mkdir /var/tmp/jdk
COPY jdk-7u80-linux-x64.tar.gz ./
RUN tar xzf ./jdk-7u80-linux-x64.tar.gz -C /var/tmp/jdk
RUN rm -rf ./jdk-7u80-linux-x64.tar.gz

# Install Tomcat
RUN mkdir /var/tmp/tomcat
RUN wget -P /var/tmp/tomcat http://www-us.apache.org/dist/tomcat/tomcat-7/v7.0.82/bin/apache-tomcat-7.0.82.tar.gz
RUN tar xzf /var/tmp/tomcat/apache-tomcat-7.0.82.tar.gz -C /var/tmp/tomcat
RUN rm -rf /var/tmp/tomcat/apache-tomcat-7.0.82.tar.gz

# Install Maven
RUN mkdir /var/tmp/maven
RUN wget -P /var/tmp/maven http://www-eu.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz
RUN tar xzf /var/tmp/maven/apache-maven-3.5.2-bin.tar.gz -C /var/tmp/maven
RUN rm -rf /var/tmp/maven/apache-maven-3.5.2-bin.tar.gz

# Set environment variables
ENV JAVA_HOME /var/tmp/jdk/jdk1.7.0_80
ENV CATALINA_HOME /var/tmp/tomcat/apache-tomcat-7.0.82
ENV M2_HOME /var/tmp/maven/apache-maven-3.5.2
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$M2_HOME/bin

#Build and copy WAR to Tomcat
RUN cd ./DukeChess/com.dexaint.dukechess && mvn package && cp ./webapps/dukechess.war /var/tmp/tomcat/apache-tomcat-7.0.82/webapps

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["./var/tmp/tomcat/apache-tomcat-7.0.82/bin/catalina.sh","run"]