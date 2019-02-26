#!/bin/bash

ENVIRONMENT=$1
IP=$2

rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum install -y puppetserver git
sed -i 's#\-Xms2g#\-Xms512m#g;s#\-Xmx2g#\-Xmx512m#g' /etc/sysconfig/puppetserver
echo -e "certname = puppet-master.dev.lsst.org" >> /etc/puppetlabs/puppet/puppet.conf
echo -e "\n[main]\nenvironment = ${ENVIRONMENT}" >> /etc/puppetlabs/puppet/puppet.conf
echo -e "\n[agent]\nserver = puppet-master.dev.lsst.org" >> /etc/puppetlabs/puppet/puppet.conf
echo -e "${IP}\tpuppet-master\tpuppet-master.dev.lsst.org" > /etc/hosts

sed -i 's#^PATH=.*#PATH=$PATH:/opt/puppetlabs/puppet/bin:$HOME/bin#g' /root/.bash_profile
/opt/puppetlabs/puppet/bin/gem install r10k

if [ ! -d /etc/puppetlabs/r10k/ ]
then
	mkdir -p /etc/puppetlabs/r10k/
fi

if [ ! -d /etc/puppetlabs/code/hieradata/ ]
then
	mkdir -p /etc/puppetlabs/code/hieradata/production
fi

if [ -d /etc/puppetlabs/code/hieradata/production ]
then
	if [ ! -z "$(grep etc_puppetlabs_code_hieradata_production /etc/fstab)" ]
   then
	    echo "etc_puppetlabs_code_hieradata_production /etc/puppetlabs/code/hieradata/production vboxsf defaults,ro 0 0" >> /etc/fstab
			mount -a
  fi
fi

echo -e "---
:cachedir: '/var/cache/r10k'

# Hiera repo not configured thru r10k since is leveraging a shared folder
:sources:
  :lsst.org:
    remote: 'https://github.com/lsst/itconf_l1ts.git'
    basedir: '/etc/puppetlabs/code/environments'
" > /etc/puppetlabs/r10k/r10k.yaml

/opt/puppetlabs/puppet/bin/r10k deploy environment -p

for f in $(ls -1 /etc/puppetlabs/code/environments/)
do
	echo "Found environment $f"
	if [ ! -d "/etc/puppetlabs/code/hieradata/$f" ]
	then
		echo "dir $f don't exists, creating it from develop"
		ln -s /etc/puppetlabs/code/hieradata/production /etc/puppetlabs/code/hieradata/$f
	fi
done

if [ -d /etc/puppetlabs/code/environments/$ENVIRONMENT ]
then
    echo "/etc/puppetlabs/code/environments/puppet-code /etc/puppetlabs/code/environments/$ENVIRONMENT none defaults,ro,bind 0 0" >> /etc/fstab
		mount -a
fi

if [ ! -f /etc/puppetlabs/puppet/autosign.conf ]
then
	echo "*.vm.dev.lsst.org" > /etc/puppetlabs/puppet/autosign.conf
fi

systemctl enable puppetserver
systemctl start puppetserver

# Registering against the puppet server and sending certificate
/opt/puppetlabs/puppet/bin/puppet agent -t

systemctl restart puppetserver


