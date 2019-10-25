# @summary
#   This class handles the scom package.
#
# @api private
#
class scom::install {
  
  package { puppet-bolt:
    ensure => present,
  }

  $basename = basename("${scom::installer_package}")

  file { "/opt/installers":
    ensure => "directory"
  }

  file { "/opt/installers/${basename}":
    ensure => file,
    source => "${scom::installer_package}",
    mode => '0744',
    recurse => true,
  }

  exec {"Install scx client":
  command => "/opt/installers/${basename} --install --enable-opsmgr",
  provider => shell,
  onlyif => '[ ! -f /usr/sbin/scxadmin ]',
  }

}
