# lsst_devops
Automatic Deployment of LSST Systems

**Requirements:**

   * VirtualBox

   * Vagrant.

To use this scripts you need first start up the puppet master VM. The network configured within this scripts is 10.0.0.0/24. All nodes have already an IP assigned and in base on those IPs the services are being configured.

**puppet-master**

To start up a Puppet Master, go into puppet-master directory and execute vagrant up. The ip for the puppet master 10.0.0.250. Hostname configure as puppet-master.dev.lsst.org.

$ vagrant up

That is going to spawn up a new VM using Virtualbox as VM backend and vagrant to manage the VMs quickly. This process will finish with an already configured VM with all the LSST puppet scripts. The domain for this environment will be dev.lsst.org. That is importante because the country tag being used by either Puppet and Telegraf will be dev.

Note: Make sure r10k_hiera_org value is not set in hiera before running the puppet master, this is to allow using hiera values from vagrant.

**nodes**

To start up a node, move to nodes directory, you need to know which node you want to deploy, this is the list of the current VMs pre-configured.

 1 EFD
 
    IP: 10.0.0.10
    Hostname: ts-efd-node-01.dev.lsst.org
    name: EFD
  
 2 influx
 
    IP: 10.0.0.251
    Hostname: gs-influxdb-node-01.dev.lsst.org
    name: influx
  
 3 grafana
 
    IP: 10.0.0.252
    Hostname: gs-grafana-node-01.dev.lsst.org
    name: grafana

 4 graylog

    IP: 10.0.0.253
    Hostname: gs-graylog-node-01.dev.lsst.org
    name: graylog

 5 DM Header Service

    IP: 10.0.0.30
    Hostname: dm-hs-node-01.dev.lsst.org
    name: dm-hs

To start up any of those, do the following:

    $ cd nodes
    $ vagrant up <name>
    $ vagrant ssh <name>

To login into the VM, execute `vagrant ssh`.
