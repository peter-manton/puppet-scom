# @summary
#   This class handles scom configuration.
#
# @api private
#
class scom::configure {

  if defined('$::issuer') {

    if $scom::certificate_issuer != $::issuer {

      file { "/etc/opt/omi/ssl/omi-host-${::hostname.downcase}.pem":
        notify => Service[omid]
      }

      service { 'omid':
        ensure => running,
      }

      #notify { "Test: $::issuer": }

      # Upload certificate to SCOM server
      exec {"upload scom certificate":
      command => "bolt file upload /etc/opt/omi/ssl/omi-host-${::hostname.downcase}.pem '${scom::scom_certificate_path}' --nodes winrm://${scom::scom_server} --user ${scom::service_user} --password ${scom::service_password} --no-ssl-verify",
      provider => shell,
      }

      # Sign the uploaded certificate
      exec {"sign certificate":
      command => "bolt command run \"scxcertconfig -sign ${scom::scom_certificate_path}omi-host-${::hostname.downcase}.pem ${scom::scom_certificate_path}omi-host-${::hostname.downcase}.signed.pem\" --nodes winrm://${scom::scom_server} --user ${scom::service_user} --password ${scom::service_password} --no-ssl-verify",
      provider => shell,
      }

      # Retrieve the signed certificate
      exec {"retrieve certificate":
      command => "bolt command run \"type ${scom::scom_certificate_path}omi-host-$hostname.signed.pem\" --nodes winrm://${scom::scom_server} --user ${scom::service_user} --password ${scom::service_password} --no-ssl-verify | sed -n '/BEGIN/,/END/p' | awk '{\$1=\$1};1' > /etc/opt/omi/ssl/omi-host-${::hostname.downcase}.pem",
      provider => shell,
      }

      # Restart the omid service
      exec {"restart omid service":
      command => "service omid restart",
      provider => shell,
      }

      # Clean up the certificates
      exec {"certificate cleanup":
      command => "bolt command run \"rm ${scom::scom_certificate_path}omi-host-${::hostname.downcase}.*\" --nodes winrm://${scom::scom_server} --user ${scom::service_user} --password ${scom::service_password} --no-ssl-verify",
      provider => shell,
      }
 
    }
  }  
}
