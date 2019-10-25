# The baseline for module testing used by Puppet Inc. is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# https://puppet.com/docs/puppet/latest/bgtm.html#testing-your-module
#
#include ::scom

class { 'scom':
    service_user => 'serviceuser',
    service_password => 'servicepassword',
    scom_server => 'scom-server01.internal',
    installer_package => 'puppet:///packages/scx-X.X.X-XXX.rhel.7.x64.sh',
    scom_certificate_path => 'C:\tmp\scx_signing_requests\\',
    winrm_ssl => true,
    certificate_issuer => 'SCOM01'
  }
