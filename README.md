# scom

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with scom](#setup)
    * [Prerequisites](#prerequisites)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Automates the installation and configuration of the SCOM SCX client on RHEL / CentOS.

## Setup

### Prerequisites 

The general process flow of the module is as follows:

- Install SCX Agent on linux box
-- Copies generated signing request to SCOM machine
--- SCOM machine signs the certificate
---- The signed certificate is sent back to linux box
----- The SCX service is restarted
------ The SCOM machine then performs a discovery (This part needs to be manually performed from the SCOM console!)

So we'll get started by preparing our SCOM host by firstly enabling WinRM: (we'll need this for signing of client certificates later):

WinRM quickconfig

(or alternatively via Group Policy)

Since we'll be using WinRM over HTTP we'll need to generate / setup our WinRM listener manually (as the above command only creates an HTTP listener)

We'll use a self-signed certificate here - however in a production envrinoment we'd obviously want it signed by a CA:

New-SelfSignedCertificate -DnsName "<dns-name>" -CertStoreLocation Cert:\LocalMachine\My

We'll then create our listener:

winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="<dns-name>"; CertificateThumbprint="<ceritficate-thumbprint-from-the-prior-command-output>"}'

You should see something like:

ResourceCreated
    Address = http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous
    ReferenceParameters
        ResourceURI = http://schemas.microsoft.com/wbem/wsman/1/config/listener
        SelectorSet
            Selector: Address = *, Transport = HTTPS
            
We'll also need to ensure that the SCOM directory is added to windows path vairable:

setx /M PATH "%PATH%;C:\Program Files\Microsoft System Center\Operations Manager\Server"

Ensure our Puppet host can communicate with WinRM:

netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986 remoteip=<puppet-ip-address>

Confirm the listener is present with:

WinRM e winrm/config/listener
            
We can now validate the new listener from the Puppet host - we need 'puppet bolt' (a tool that provides clientless administration of Windows and Linux systems):

sudo rpm -Uvh https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm
sudo yum install puppet-bolt

Note: The Puppet module should perform this automatically for you providing you have the Puppet RHEL 7 repository configured.

and then upload a test file to test it with:

echo 'testfile' > test.txt
bolt file upload test.txt 'C:\temp'  --nodes winrm://<dns-name> --user <service-user> --password <password> --no-ssl-verify


Create a server mount point for Puppet to store the SCX binaries:

cat <<EOT >> /etc/puppetlabs/puppet/fileserver.conf
[installer_files]
    path /etc/puppetlabs/puppet/installer_files
    allow *
EOT

You can now copy all of the SCX client installation files to the mount point - the typical location is: 'C:\Program Files\Microsoft System Center\Operations Manager\Server\AgentManagement\UnixAgents\DownloadedKits\'

Now on the SCOM host we'll create a dedicated shared folder for signing requests:

mkdir C:\temp\scx_signing_requests

net share scx_signing_requests=C:\temp\scx_signing_requests /GRANT:<service-user>,FULL

### Beginning with scom

Please refer to examples folder.

## Usage

Please refer to examples folders.

## Reference

class scom (
  String $service_user, # Service username to connect to SCOM server via WinRM
  String $service_password, # Server password to connect to SCOM server via WinRM
  String $scom_server, # SCOM server DNS name / IP address
  String $installer_package, # Path to SRX agent installation file 
  String $scom_certificate_path, # Directory where signing requests are stored on SCOM server
  String $certificate_issuer, # Usually hostname of the SCOM server (it's case sensitive!)
  Optional[Boolean] $winrm_ssl # Optionally disable SSL with WinRM (not currently implemented) 
)


## Limitations

This only currently works with RHEL 7 / CentOS. Future support for more operating systems may be added if there is popular demand.

## Development

https://github.com/peter-manton/puppet-scom
