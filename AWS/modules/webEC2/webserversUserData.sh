#!/bin/bash -x
echo "-------------------------START-----------------------------"
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
retryCommand 5 10 "yum -y install tomcat tomcat-webapps tomcat-admin-webapps \
                   tomcat-docs-webapp tomcat-javadoc"
mv /var/lib/tomcat/webapps/ROOT/ /var/lib/tomcat/webapps/default-ROOT
wget https://snakes-app.s3.amazonaws.com/ROOT.war
mv ROOT.war /var/lib/tomcat/webapps/
systemctl start tomcat
systemctl enable tomcat
sleep 10s
curl -sS http://localhost:8080 | grep "Does it have snakes?"
