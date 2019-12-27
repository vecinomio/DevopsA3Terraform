#!/bin/bash -x
echo "-------------------------START-----------------------------"
tomcat_version=${tomcat_version}
tomcat_ver_maj_okt=$(echo ${tomcat_version} | cut -d '.' -f 1)
function retryCommand() {
    local ATTEMPTS="$1"
    local SLEEP="$2"
    local FUNCTION="$3"
    for i in $(seq 1 $ATTEMPTS); do
        [ $i == 1 ] || sleep $SLEEP
        eval $FUNCTION && echo $? && break || echo $?
    done
}
echo "-------------INSTALLING TOMCAT AND DEPLOY APP--------------"
cd /tmp
retryCommand 5 10 "yum install java-1.8.0-openjdk -y"
retryCommand 5 10 "aws s3 cp 's3://snakes-app/ROOT.war' ."
wget http://apache.volia.net/tomcat/tomcat-$tomcat_ver_maj_okt/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz
tar xzf apache-tomcat-${tomcat_version}.tar.gz
mv apache-tomcat-${tomcat_version}/ /usr/local/tomcat/ && rm apache-tomcat-${tomcat_version}.tar.gz
mv /usr/local/tomcat/webapps/ROOT/ /usr/local/tomcat/webapps/default-ROOT
mv ROOT.war /usr/local/tomcat/webapps/
/usr/local/tomcat/bin/catalina.sh start

retryCommand 5 10 "curl -sS http://localhost:8080 | grep 'Does it have snakes?'"
echo "-------------------------FINISH----------------------------"
