for ns in $(kgns -oname|cut -d"/" -f2|tail -n+2); do krmpon $ns $(kgpon $ns|grep -i evicted| awk '{print $1}') --force --grace-period=0; done
