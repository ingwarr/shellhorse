#!/bin/bash
# Use this script to find your forgotten envs.

username="$(whoami)"

servers=(cz5578.bud.mirantis.net
         cz7764.bud.mirantis.net
         cz7363.bud.mirantis.net
         cz7364.bud.mirantis.net
         cz7918.bud.mirantis.net)

for server in ${servers[*]}
do
    printf "Check on %s server \n" $server
    ssh ${server} -q "virsh list --all | grep ${username}"
done
