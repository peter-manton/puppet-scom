# Class: scom
# ===========================
#
# Full description of class scom here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'scom':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2019 Your name here, unless otherwise noted.
#
class scom (
  String $service_user,
  String $service_password,
  String $scom_server,
  String $installer_package,
  String $scom_certificate_path,
  String $certificate_issuer,
  Optional[Boolean] $winrm_ssl
)

  {
  notify { "Applying scom class...": }

  contain scom::install
  contain scom::configure

  Class['::scom::install']
  -> Class['::scom::configure']

  }
