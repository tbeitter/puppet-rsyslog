# == Class: rsyslog::install
#
# This class makes sure that the required packages are installed
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'rsyslog::install': }
#
class rsyslog::install {
  if $rsyslog::rsyslog_package_name != false {
    package { $rsyslog::rsyslog_package_name:
      ensure => $rsyslog::package_status,
    }
  }

  if $rsyslog::relp_package_name != false {
    package { $rsyslog::relp_package_name:
      ensure => $rsyslog::package_status
    }
  }

  if $rsyslog::gnutls_package_name != false {
    package { $rsyslog::gnutls_package_name:
      ensure => $rsyslog::package_status
    }
  }

}

class rsyslog::install::logstash {
  
  $elastic_packages = [ "openjdk-7-jre-headless", "elasticsearch", "logstash" ]

  apt::key { 'elasticsearch':
    key => 'D88E42B4',
  } 

  apt::source { 'elasticsearch':
    location    => 'http://packages.elasticsearch.org/elasticsearch/1.6/debian',
    release     => 'stable',
    repos       => 'main',
    require     => Apt::Key['elasticsearch'],
    include_src => false,
  }

  apt::source { 'logstash':
    location    => 'http://packages.elasticsearch.org/logstash/1.5/debian',
    release     => 'stable',
    repos       => 'main',
    require     => Apt::Key['elasticsearch'],
    include_src => false,
  }

  package { $elastic_packages:
    ensure          => installed,
    install_options => ['--no-install-recommends'],
    require         => [ Apt::Source["elasticsearch"], Apt::Source["logstash"] ]
  }

  service { 'logstash':
    ensure => running,
    require => [ Package['logstash'], Exec['install-relp-plugin'] ]
  }

  service { 'elasticsearch':
    ensure => running,
    require => Package['elasticsearch'],
  }

  # disabled for testing, too slow VMs
  exec { 'install-relp-plugin':
    command => '/opt/logstash/bin/plugin install logstash-input-relp',
    #unless  => '/opt/logstash/bin/plugin update logstash-input-relp',
    #unless  => '/usr/bin/test -d /opt/logstash/vendor/bundle/jruby/*/gems/logstash-input-relp*',
    unless  => '/opt/logstash/bin/plugin list | grep logstash-input-relp',
    timeout => '600',
    require => Package["logstash"]
  }

  file { '/etc/logstash/conf.d/relp.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template('rsyslog/server_relp.conf.erb'),
    notify  => Service['logstash']
  }


}
