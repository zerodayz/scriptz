# CoreDNS

Running external CoreDNS and resolving your pods running in Kubernetes cluster.


```
.:53 {
   kubernetes cluster.local {
    endpoint https://api-fcos-k8s-local:6443
    kubeconfig /home/robin/.kube/config default/api-fcos-k8s-local:6443/system:admin
    pods insecure
  }
}
```

`coredns -conf /etc/coredns/Corefile`


```
$ dig @localhost kubernetes.default.svc.cluster.local

; <<>> DiG 9.11.18-RedHat-9.11.18-1.fc32 <<>> @localhost kubernetes.default.svc.cluster.local
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 43825
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: cada72283edf8122 (echoed)
;; QUESTION SECTION:
;kubernetes.default.svc.cluster.local. IN A

;; ANSWER SECTION:
kubernetes.default.svc.cluster.local. 5 IN A    172.30.0.1

;; Query time: 0 msec
;; SERVER: ::1#53(::1)
;; WHEN: Fri May 01 18:28:42 AEST 2020
;; MSG SIZE  rcvd: 129


$ oc get svc | grep 172.30.0.1
kubernetes   ClusterIP      172.30.0.1   <none>                                 443/TCP   6h56m
```