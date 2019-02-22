# lsst_devops
Automatic Deployment of LSST Systems

**Requirements:**

   * VirtualBox

   * VirtualBox Guests Additions

   * Vagrant.

To use this scripts you need first to start up the puppet master VM. The network configured within this scripts is 10.0.0.0/24. All nodes have already an IP assigned and based on those IPs the services are being configured.

**vagrant-vbguest**

In order to mount the hiera folder into the VM, you need to first install the VirtualBox Guest Additions. Go into the puppet-master directory and run

      vagrant plugin install vagrant-vbguest

**puppet-master**

To start up a Puppet Master, go into puppet-master directory and execute vagrant up. The ip for the puppet master is 10.0.0.250. Hostname configured as puppet-master.dev.lsst.org.

      vagrant up

That is going to spawn up a new VM using Virtualbox as VM backend and vagrant to manage the VMs quickly. This process will finish with an already configured VM with all the LSST puppet scripts. The domain for this environment will be dev.lsst.org. That is important because the country tag being used by either Puppet and Telegraf will be dev.

If there is given branch from the puppet code that you would like to test, then make sure you have the right environment configured on the nodes' database.

      cd puppet-master
      vagrant ssh 
      sudo su -
      admin.py -l

The commands above will list all the nodes definitions configured in puppet. Depending on the host you want to work on, you may want to use a different environment. You can do that in 2 different ways, by modifying the CSV files in where all those definitions are, or by modifying the current DB (sqlite file). I would rather prefer the second options since is a temporay change.

Example: 

      admin.py -u --node-def ts-efd -a environment=IT_971_avillalobo

Note that the environments database is configured in hiera, this repo as of today, is using the same repo I'm using for the Chilean services, I try to keep everything in production, but is always safer to double check which environment is given to your node.

Note: Make sure r10k_hiera_org value is not set in hiera before running the puppet master, this is to allow using hiera values from vagrant.

If you destroy a node and wants to re-provision it. You should also clean the SSL keys stored in the puppet master. That's it because when a node gets registered with the puppet master, it self sign the provided certificate from the node, if you destroy the VM and create a new one with the exact same hostname, the node will create a different SSL certificate that will have conflicts in the puppet master, therefore, is safer to, every time you destroy a VM, clean its associated SSL key. In order to do so:

      cd puppet-master
      vagrant ssh 
      sudo su -
      puppet cert list -a # which will list all the already signed certificates
      puppet cert clean [<fqdn>]{1,N}

Example:

      puppet cert clean ts-efd-srv-01.vm.dev.lsst.org ts-efd-mgmt-01.vm.dev.lsst.org ts-efd-data-02.vm.dev.lsst.org ts-efd-data-01.vm.dev.lsst.org

**Nodes**

To start up a node, move to nodes directory, there is a directory called designs, in where different yaml files are created, each yaml file describes a cluster within the same network range, so be careful about the IPs used.

      nodes/
      ├── Makefile
      ├── Vagrantfile
      └── designs
         ├── Vagrant_all.yaml
         ├── Vagrant_efd.yaml
         └── Vagrant_monitoring.yaml

The Vagrant_all.yaml have several nodes described which you can start up individually. The content of each specific cluster definition may or may not be in the Vagrant_all.yaml file, however you need to make sure that there is no repeated IPs that may have conflicts when starting up, as well as the hostname.

The main goal of this repo, is to have a set of different designs that better fulfill a given requirement, each yaml file will have a desired design for an infrastructure, in such a way that you can design how your system will behave and vagrant plus puppet will orchestrate that for you.

**PODs**

***EFD***

If you want to start up the EFD, you can leverage the makefile under nodes to do so.

      make start_efd

To verify the cluster's status:

      make status_efd      

If all your nodes (or at least the node your are interested on) are running, you can connect to it using vagrant ssh.

Example:

      vagrant --design=designs/Vagrant_efd.yaml ssh ts-efd-srv-01

the current options for the EFD are:

      make start_efd
      make destroy_efd
      make halt_efd
      make reload_efd
      make status_efd

***Monitoring Cluster***

If you want to start up the Monitoring, you can leverage the makefile under nodes to do so.

      make start_monitoring

To verify the cluster's status:

      make status_monitoring

If all your nodes (or at least the node your are interested on) are running, you can connect to it using vagrant ssh.

Example:

      vagrant --design=designs/Vagrant_monitoring.yaml ssh ts-grafana-node-01

the current options for the Monitoring are:

      make start_monitoring
      make destroy_monitoring
      make halt_monitoring
      make reload_monitoring
      make status_monitoring

***General***

There are more other definitions in the Vagrant_all.yaml that you can explore. If you want to start up any of those, you can do:

      vagrant up <VM name>

To connect:

      vagrant ssh <VM Name>

The vm name is the key of the yaml file that describes the VM.