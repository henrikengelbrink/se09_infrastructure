#!/usr/bin/env bash

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

READY=0
while [ "$READY" -eq 0 ]; do
    EXT_IP=`kubectl --kubeconfig ./kubeconfig.yaml get svc voyager-main-ingress -n voyager | awk 'FNR==2 { print $4 }'`
    if valid_ip $EXT_IP; then 
        READY=1
        echo 'End point ready:' && echo $EXT_IP
    else
        sleep 10 
    fi
done

