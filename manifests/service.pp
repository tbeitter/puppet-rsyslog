# == Class: rsyslog::service
#
# This class enforces running of the rsyslog service.
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'rsyslog::service': }
#
class rsyslog::service {
  service { $rsyslog::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => $rsyslog::service_hasstatus,
    hasrestart => $rsyslog::service_hasrestart,
    require    => Class['rsyslog::config'],
  }
}

class rsyslog::logstash::service {
  service { $rsyslog::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['rsyslog::logstash::config'],
  }
}
