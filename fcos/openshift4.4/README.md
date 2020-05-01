# OpenShift 4.4 UPI (wip)
Note: This is not official guide, it doesn't contain recommended practices, neither recommended HW requirements.

# Requirements
## Masters requirements
Number of nodes: **3**  
Memory: **16384** MB  
Disk: **40** GB
vCPUs: **4**

## Workers requirements
Number of nodes: **1**  
Memory: **8192** MB  
Disk: **20** GB
vCPUs: **2**

## Bootstrap requirements
Number of nodes: **1**  
Memory: **2048** MB  
Disk: **20** GB
vCPUs: **4**

# Installation Steps

This is provisioning all the nodes as VMs

Register your node and subscribe to the relevant repositories.

```
subscription-manager repos --disable=* --enable=rhel-7-server-rpms \
--enable=rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms \
--enable=rhel-7-server-rhv-4-mgmt-agent-rpms
```
I am subscribing to **RHV 4** repository for latest version of qemu.

## Install and enable libvirt
```
yum install -y libvirt libvirt-devel libvirt-daemon-kvm qemu-kvm-rhev virt-install
systemctl enable --now libvirtd
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf
```

Setup host for remote `virt-manager` connections

```
ssh-copy-id root@$HOST
```

I will connect to the remote server using `virt-manager` running on my Fedora.

1. Start virt-manager.
2. Open the File->Add Connection menu.
3. Input values for the hypervisor type, the connection, connect to remote host
over SSH, and enter the desired hostname, then click connect.
 
Note: Initial connection may take several minutes, it took around 3-5 minutes in my environment.

**In other terminal** connect to the remote host over SSH

```
ssh root@$HOST
```

The scripts expects you have at least 160GB of disk free in `/var/lib/libvirt/images`
however it's not available in my environment.

I am going to have to reduce the size of all nodes to 15GB. Lowering down the
total size of all disks together to 60GB.

# Let's start provisioning

```
git clone https://github.com/zerodayz/kubernetes.git
```

## Configure Host DNS server

```
cd /root/kubernetes/fcos/openshift4.4
bash configure-bind.sh
# Verification
systemctl status named
```

## Configure host HAproxy server

```
cd /root/kubernetes/fcos/openshift4.4
bash configure-haproxy.sh
# Verification
systemctl status haproxy
ss -tulnp | grep 6443
```

## Download the CoreOS images

```
cd /root/kubernetes/fcos/openshift4.4
bash get-images.sh
# Verification
ls images/
fedora-coreos-31.20191210.3.0-installer-initramfs.x86_64.img  fedora-coreos-31.20191210.3.0-installer.x86_64.iso
fedora-coreos-31.20191210.3.0-installer-kernel-x86_64         fedora-coreos-31.20191210.3.0-metal.x86_64.raw.xz
```

## Configure Libvirt network

Since there is already default network with the same subnet we are using,
I am going to remove that one and provision new one.

```
cd /root/kubernetes/fcos/openshift4.4
virsh net-destroy default
virsh net-undefine default
virsh net-define libvirt-net.yaml 
virsh net-start openshift
virsh net-autostart openshift
# Verification
virsh net-dumpxml openshift
<network>
  <name>openshift</name>
  <uuid>2a240d75-62ec-4008-9638-155684679b3e</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:6a:0e:33'/>
  <domain name='k8s.local'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
  </ip>
</network>
```

## Get the OpenShift Client

```
cd /root/kubernetes/fcos/openshift4.4
bash get-client.sh
# Verification
which openshift-install
/usr/local/bin/openshift-install
which oc
/usr/local/bin/oc
```

## Copy the cloud.redhat.com secret 

1. Click on "**Run on Baremetal**" or directly 
[https://cloud.redhat.com/openshift/install/metal/user-provisioned](https://cloud.redhat.com/openshift/install/metal/user-provisioned)
-> **Copy pull secret**

2. Copy the ssh public key

```
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub
```
## Modify install-config.yaml

Paste both the pull secret and ssh key into the `install-config.yaml`

```
pullSecret: '{"auths":{"cloud.openshift.com":{"auth":"....}'
sshKey: 'ssh-rsa....'
```

## Create ignition files

```
cd /root/kubernetes/fcos/openshift4.4
bash create-ign.sh
# Verification
ls deploy/
auth  bootstrap.ign  master.ign  metadata.json  worker.ign
```

## Prepare network configuration for the VMs

```
cd /root/kubernetes/fcos/openshift4.4
bash fakeroot-network-config.sh 
# Verification
 ls fedora-*
fedora-bootstrap:
etc

fedora-master-0:
etc

fedora-master-1:
etc

fedora-master-2:
etc

fedora-worker-0:
etc
```

## Install filetranspiler

Requires podman, install with `yum -y install podman`

```
cd /root/kubernetes/fcos/openshift4.4
bash install-filetranspiler.sh
# Verification
podman images | grep filetranspiler
localhost/filetranspiler            latest   5aac53e333af   2 minutes ago   407MB
```

## Create new ignition files with network configuration

```
cd /root/kubernetes/fcos/openshift4.4
bash fakeroot-create-bootstrap.sh
# Verification
ls -la ignition/
total 312
drwxr-xr-x.  2 root root    107 Apr 30 08:04 .
drwxr-xr-x. 13 root root   4096 Apr 30 08:04 ..
-rw-r--r--.  1 root root 295533 Apr 30 08:04 bootstrap.ign
-rw-r--r--.  1 root root   2166 Apr 30 08:04 master-0.ign
-rw-r--r--.  1 root root   2166 Apr 30 08:04 master-1.ign
-rw-r--r--.  1 root root   2166 Apr 30 08:04 master-2.ign
-rw-r--r--.  1 root root   2166 Apr 30 08:04 worker-0.ign
```

## Let's start provisioning VMs

## Start Webserver

```
cd /root/kubernetes/fcos/openshift4.4
python -m SimpleHTTPServer &
```

or on Fedora

```
cd /root/kubernetes/fcos/openshift4.4
python -m http.server &
```

## Bootstrap node

Open your `virt-manager` and connect to your remote host over SSH.

While in the terminal run VM creation script

```
cd /root/kubernetes/fcos/openshift4.4
bash vm-create-bootstrap.sh
```

You should see VM spawning in your `virt-manager`, open VNC console and watch the installation.

After the installation is finished, and **the node is rebooted**.
Then **Force off** the VM.

In `virt-manager` click Open -> Boot Options -> untick **Enable direct kernel boot**
and **Apply**

Look at the assigned MAC address and add it to the libvirt net

```
virsh net-edit openshift
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.124' end='192.168.122.254'/>
      <host mac='52:54:00:b4:5b:db' name='fedora-bootstrap' ip='192.168.122.9'/>
    </dhcp>
  </ip>
```

Do the same with the other nodes:

## Master node 0

```
cd /root/kubernetes/fcos/openshift4.4
bash vm-create-master.sh 0
```

You should see VM spawning in your `virt-manager`, open VNC console and watch the installation.

After the installation is finished, and **the node is rebooted**.
Then **Force off** the VM.

In `virt-manager` click Open -> Boot Options -> untick **Enable direct kernel boot**
and **Apply**

Look at the assigned MAC address and add it to the libvirt net

```
virsh net-edit openshift
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.124' end='192.168.122.254'/>
      <host mac='52:54:00:b4:5b:db' name='fedora-bootstrap' ip='192.168.122.9'/>
      <host mac='52:54:00:43:15:b9' name='fedora-master-0' ip='192.168.122.10'/>
    </dhcp>
  </ip>
```

Always power off the node, change settings in `virt-manager` and move to the next one.


## Master node 1

```
cd /root/kubernetes/fcos/openshift4.4
bash vm-create-master.sh 1
```

You should see VM spawning in your `virt-manager`, open VNC console and watch the installation.

After the installation is finished, and **the node is rebooted**.
Then **Force off** the VM.

In `virt-manager` click Open -> Boot Options -> untick **Enable direct kernel boot**
and **Apply**

Look at the assigned MAC address and add it to the libvirt net

```
virsh net-edit openshift
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.124' end='192.168.122.254'/>
      <host mac='52:54:00:b4:5b:db' name='fedora-bootstrap' ip='192.168.122.9'/>
      <host mac='52:54:00:43:15:b9' name='fedora-master-0' ip='192.168.122.10'/>
      <host mac='52:54:00:bd:24:5d' name='fedora-master-1' ip='192.168.122.11'/>
    </dhcp>
  </ip>
```

Always power off the node, change settings in `virt-manager` and move to the next one.

## Master node 2

```
cd /root/kubernetes/fcos/openshift4.4
bash vm-create-master.sh 2
```

You should see VM spawning in your `virt-manager`, open VNC console and watch the installation.

After the installation is finished, and **the node is rebooted**.
Then **Force off** the VM.

In `virt-manager` click Open -> Boot Options -> untick **Enable direct kernel boot**
and **Apply**

Look at the assigned MAC address and add it to the libvirt net

```
virsh net-edit openshift
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.124' end='192.168.122.254'/>
      <host mac='52:54:00:b4:5b:db' name='fedora-bootstrap' ip='192.168.122.9'/>
      <host mac='52:54:00:43:15:b9' name='fedora-master-0' ip='192.168.122.10'/>
      <host mac='52:54:00:bd:24:5d' name='fedora-master-1' ip='192.168.122.11'/>
      <host mac='52:54:00:fd:70:b3' name='fedora-master-2' ip='192.168.122.12'/>
    </dhcp>
  </ip>
```

Always power off the node, change settings in `virt-manager` and move to the next one.

## Worker node 0

```
cd /root/kubernetes/fcos/openshift4.4
bash vm-create-worker.sh
```

You should see VM spawning in your `virt-manager`, open VNC console and watch the installation.

After the installation is finished, and **the node is rebooted**.
Then **Force off** the VM.

In `virt-manager` click Open -> Boot Options -> untick **Enable direct kernel boot**
and **Apply**

Look at the assigned MAC address and add it to the libvirt net

```
virsh net-edit openshift
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.124' end='192.168.122.254'/>
      <host mac='52:54:00:b4:5b:db' name='fedora-bootstrap' ip='192.168.122.9'/>
      <host mac='52:54:00:43:15:b9' name='fedora-master-0' ip='192.168.122.10'/>
      <host mac='52:54:00:bd:24:5d' name='fedora-master-1' ip='192.168.122.11'/>
      <host mac='52:54:00:fd:70:b3' name='fedora-master-2' ip='192.168.122.12'/>
      <host mac='52:54:00:65:82:97' name='fedora-worker-0' ip='192.168.122.13'/>
    </dhcp>
  </ip>
```

Always power off the node, change settings in `virt-manager` and move to the next one.


At the end you should have something like this

```
virsh net-dumpxml openshift
<network>
  <name>openshift</name>
  <uuid>2a240d75-62ec-4008-9638-155684679b3e</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:6a:0e:33'/>
  <domain name='k8s.local'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.124' end='192.168.122.254'/>
      <host mac='52:54:00:b4:5b:db' name='fedora-bootstrap' ip='192.168.122.9'/>
      <host mac='52:54:00:43:15:b9' name='fedora-master-0' ip='192.168.122.10'/>
      <host mac='52:54:00:bd:24:5d' name='fedora-master-1' ip='192.168.122.11'/>
      <host mac='52:54:00:fd:70:b3' name='fedora-master-2' ip='192.168.122.12'/>
      <host mac='52:54:00:65:82:97' name='fedora-worker-0' ip='192.168.122.13'/>
    </dhcp>
  </ip>
</network>
```

## Finish installation of Boostrap node

Start the bootstrap node again and ssh as the user **core**

```
ssh core@192.168.122.9
```

Wait until installation completes, you can view the logs

```
journalctl -b -f -u release-image.service -u bootkube.service
```

If you are seeing DNS resolution problems:

```
 Get https://quay.io/v2/: dial tcp: lookup quay.io on [::1]:53: read udp
[::1]:35698->[::1]:53: read: connection refused
```

That means the DNS configuration didn't work and you need to set resolver manually

```
sudo su -
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

The bootstrap node now will update itself and reboot.

```
Connection to 192.168.122.9 closed by remote host.
Connection to 192.168.122.9 closed.
```

After reboot the bootstrap node will start Kubernetes installation.

```
ssh core@192.168.122.9
```

Wait until installation completes, you can view the logs

```
journalctl -b -f -u release-image.service -u bootkube.service
```

Then you should see everything progressing. When you start seeing messages such as

```
Apr 30 14:06:22 fedora-bootstrap bootkube.sh[643]: "99_openshift-machineconfig_99-master-ssh.yaml": unable to get REST mapping for "99_openshift-machineconfig_99-master-ssh.yaml": no matches for kind "MachineConfig" in version "machineconfiguration.openshift.io/v1"
Apr 30 14:06:22 fedora-bootstrap bootkube.sh[643]: "99_openshift-machineconfig_99-worker-ssh.yaml": unable to get REST mapping for "99_openshift-machineconfig_99-worker-ssh.yaml": no matches for kind "MachineConfig" in version "machineconfiguration.openshift.io/v1"
```

Check for ports  6443 and 22623

```
s -tulnp | grep 6443
tcp    LISTEN  0       4096                      *:6443                 *:*      users:(("kube-apiserver",pid=5762,fd=7))                                       
ss -tulnp | grep 22623 
tcp    LISTEN  0       4096                      *:22623                *:*      users:(("machine-config-",pid=4711,fd=6)) 
```

You can start provisioning other servers.

## Master nodes
## Finish installation of Master node

Start the master nodes again and ssh as the user **core**

```
ssh core@192.168.122.1{N}
```

And check they have right DNS server configured. If not run

```
sudo su -
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

The nodes will reboot once they update to the latest.

## Monitoring the progress
To monitor the installation you should be able now to execute

```
cd /root/kubernetes/fcos/openshift4.4/deploy/
export KUBECONFIG=auth/kubeconfig
openshift-install wait-for bootstrap-complete --log-level debug
```

### Bootstrap

This is example how it looks when bootstrap node is finished

```
openshift-install wait-for bootstrap-complete --log-level debug
DEBUG OpenShift Installer 4.4.0-0.okd-2020-04-21-163702-beta4 
DEBUG Built from commit 05427285086348912f5183c0ac39094c75e0c1db 
INFO Waiting up to 20m0s for the Kubernetes API at https://api.fcos.k8s.local:6443... 
INFO API v1.17.1 up                               
INFO Waiting up to 40m0s for bootstrapping to complete... 
DEBUG Bootstrap status: complete                   
INFO It is now safe to remove the bootstrap resources 
```

To update haproxy and remove LB run

```
cd /root/kubernetes/fcos/openshift4.4/
bash finished-bootstrap.sh
```

## Worker nodes

After all your master nodes are healthy and running

```
kubectl get nodes
NAME              STATUS   ROLES    AGE     VERSION
fedora-master-0   Ready    master   3h46m   v1.17.1
fedora-master-1   Ready    master   122m    v1.17.1
fedora-master-2   Ready    master   122m    v1.17.1
```

And you are not seeing any pods **crashing**

Start up your worker nodes and they will bootstrap off the masters.


If everything went fine, here is what you should see

```
# openshift-install wait-for install-complete --log-level debug
DEBUG OpenShift Installer 4.4.0-0.okd-2020-04-21-163702-beta4 
DEBUG Built from commit 05427285086348912f5183c0ac39094c75e0c1db 
DEBUG Fetching Install Config...                   
DEBUG Loading Install Config...                    
DEBUG   Loading SSH Key...                         
DEBUG   Loading Base Domain...                     
DEBUG     Loading Platform...                      
DEBUG   Loading Cluster Name...                    
DEBUG     Loading Base Domain...                   
DEBUG     Loading Platform...                      
DEBUG   Loading Pull Secret...                     
DEBUG   Loading Platform...                        
DEBUG Using Install Config loaded from state file  
DEBUG Reusing previously-fetched Install Config    
INFO Waiting up to 30m0s for the cluster at https://api.fcos.k8s.local:6443 to initialize... 
DEBUG Still waiting for the cluster to initialize: Working towards 4.4.0-0.okd-2020-04-21-163702-beta4: 99% complete 
DEBUG Still waiting for the cluster to initialize: Cluster operator authentication is still updating 
DEBUG Still waiting for the cluster to initialize: Cluster operator authentication is still updating 
DEBUG Cluster is initialized                       
INFO Waiting up to 10m0s for the openshift-console route to be created... 
DEBUG Route found in openshift-console namespace: console 
DEBUG Route found in openshift-console namespace: downloads 
DEBUG OpenShift console route is created           
INFO Install complete!                            
INFO To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=/root/kubernetes/fcos/openshift4.4/deploy/auth/kubeconfig' 
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.fcos.k8s.local 
INFO Login to the console with user: kubeadmin, password: XXXXXX
```

The outcome is 3 masters and 1 worker node

```
NAME              STATUS   ROLES    AGE     VERSION
fedora-master-0   Ready    master   4h58m   v1.17.1
fedora-master-1   Ready    master   3h14m   v1.17.1
fedora-master-2   Ready    master   3h14m   v1.17.1
fedora-worker-0   Ready    worker   58m     v1.17.1
```
