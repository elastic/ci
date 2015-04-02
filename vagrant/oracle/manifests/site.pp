exec { "apt-update":
    command => "/bin/yum check-update",
    returns => [0, 100],
}

Exec["apt-update"] -> Package <| |>

Package { ensure => "latest" }
$enhancers = [
 'java-1.8.0-openjdk-devel.x86_64',
 'augeas-devel.x86_64',
 'git',
 'ruby',
 'curl',
]
package { $enhancers: }

# make sure jenkins user exists 
$jenkins_dirs = [ "/home/jenkins", "/mnt/jenkins"]


file { $jenkins_dirs:
  ensure => "directory",
  owner => "jenkins",
  group => "jenkins",
  mode => 755,
  require => [ User[jenkins], Group[jenkins] ],
}

group { 'jenkins':
  ensure => "present",
}

user { "jenkins":
  ensure => "present",
  home => "/home/jenkins",
  name => "jenkins",
  shell => "/bin/bash",
  managehome => true,
}

augeas { "sysctl":
  context => "/files/etc/sysctl.conf",
  changes => [
    "set fs.file-max 100000",
    "set 'net.core.wmem_max' 12582912",
    "set net.core.rmem_max 12582912",
    "set net.ipv4.tcp_rmem '10240 87380 12582912'",
    "set net.ipv4.tcp_wmem '10240 87380 12582912'",
    "set net.ipv4.tcp_window_scaling 1",
    "set net.ipv4.tcp_timestamps 1",
    "set net.ipv4.tcp_sack 1",
    "set net.ipv4.tcp_no_metrics_save 1",
    "set net.core.netdev_max_backlog 5000",
    "set net.ipv6.conf.all.disable_ipv6 1",
    "set net.ipv6.conf.default.disable_ipv6 1",
    "set net.ipv6.conf.lo.disable_ipv6 1",
  ],
}

exec{'retrieve_slave_jar':
  command => '/bin/wget -q http://build-eu-00.elastic.co/jnlpJars/slave.jar -O /mnt/jenkins/slave.jar',
  creates => '/mnt/jenkins/slave.jar',
  require => File['/mnt/jenkins'],
  }

file { '/mnt/jenkins/slave.jar':
  mode => 0755,
  owner => "jenkins",
  group => "jenkins",
  require => Exec['retrieve_slave_jar'],
}


file_line { 'limit jenkins hard':
  path => '/etc/security/limits.conf',
  line => "jenkins\thard\tnofile\t10240",
}

file_line { 'limit jenkins soft':
  path => '/etc/security/limits.conf',
  line => "jenkins\tsoft\tnofile\t10240",
}

file_line { 'limit root hard':
  path => '/etc/security/limits.conf',
  line => "root\thard\tnofile\t10240",
}

file_line { 'limit root soft':
  path => '/etc/security/limits.conf',
  line => "root\tsoft\tnofile\t10240",
}

#Add jenkins key
file { "/home/jenkins/.ssh":
    ensure            =>  directory,
    mode              =>  '0700',
    require => File['/home/jenkins']
  }

ssh_authorized_key {'jenkins':
      ensure          => present,
      name            => 'jenkins@elasticsearch',
      user            => 'jenkins',
      type            => 'ssh-rsa',
      key             => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC5PkpoIpSPqMBMGmEUvL3TX+pLfzv9ezl7YOPCs2Werng0b35p5nn3yypZ+uS61h9HS7LamIqvxj8KjRgsCRf/2vX3VemrMlfSobusNqNaBaJLucn+xqy4PKxBzqVzQxkgXF5SHlg1FPBy+GKWLPSzEe/otINhOMj5StfwKqeyri4f9PJq8tAfZvPXxCnzsrFfP+058gOTtHfGJfBxeV2OGyJOWlBVWradjmTLS/lWUdzs2o+vxqZjH8GDBNFCzHhL3tJw4xez4IMEyMuDhoQFS1+H3I4Ni+QdrI9xh6MOAkBPEPxIt6b5iNOSZjkSZyKiB91F5Qap/QYvEHl0UPgj',
}

