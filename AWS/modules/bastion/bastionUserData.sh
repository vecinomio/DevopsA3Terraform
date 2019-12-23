#!/bin/bash -x
echo "-------------------------START-----------------------------"
instanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
function retryCommand() {
    local ATTEMPTS="$1"
    local SLEEP="$2"
    local FUNCTION="$3"
    for i in $(seq 1 $ATTEMPTS); do
        [ $i == 1 ] || sleep $SLEEP
        eval $FUNCTION && echo $? && break || echo $?
    done
}
echo "---------------------ASSOCIATING EIP-----------------------"
retryCommand 5 10 "aws ec2 associate-address --instance-id $instanceId \
                  --allocation-id ${eipId} --region ${region}"
