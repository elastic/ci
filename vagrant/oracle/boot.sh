#!/bin/bash
vagrant box list | grep oracle
rc=$? 
if [[ $rc != 0 ]]
then
  vagrant box add oracle http://cloud.terry.im/vagrant/oraclelinux-7-x86_64.box
  vagrant destroy
fi
vagrant up
