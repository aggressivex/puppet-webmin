# Class: webmin::setup
#
# This class installs webmin for CentOS / RHEL
#
define webmin::setup (
  $cutomSetup = {},
  $cutomConf  = {},
  $ensure     = installed,
  $boot       = true,
  $status     = 'running',
  $firewall   = false,
  $port       = 10000,
) {

  include conf
  $defaultConf = $conf::conf
  $defaultSetup = $conf::setup

  yumrepo { "webmin":
    baseurl  => "http://download.webmin.com/download/yum",
    descr    => "Webmin Distribution Neutral",
    enabled  => 1,
    gpgcheck => 0,
  }

  package { 'webmin':
    ensure => "present",
    require => Yumrepo["webmin"]
  }

  service { 'webmin':
    name       => 'webmin',
    ensure     => $status,
    enable     => $boot,
    hasrestart => true,
    hasstatus  => true,
    require    => Package ['webmin']
  }

  case $firewall {
    csf: {
      csf::port::open {'webmin-firewall-csf-open':
        port => $port
      }
    }
    iptables: {
      exec { "webmin-firewall-iptables-add":
        command => "iptables -A INPUT -p tcp --dport ${port} -j ACCEPT",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
        require => Package["bind"]
      }
      exec { "webmin-firewall-iptables-save":
        command => "service iptables save",
        path    => "/usr/local/bin/:/bin/:/usr/bin/:/usr/sbin:/sbin/",
        require => Exec["bind-firewall-iptables-add"]
      }
    }
  }
}