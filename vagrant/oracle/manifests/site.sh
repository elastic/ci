#!/bin/bash
yum upgrade -y
yum install -y puppet
puppet module install puppetlabs-stdlib
puppet apply /vagrant_data/manifests/site.pp
