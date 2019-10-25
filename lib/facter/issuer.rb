Facter.add(:issuer) do
  setcode "/usr/bin/openssl x509 -text -noout -in /etc/opt/omi/ssl/omi-host-`hostname | awk '{print tolower($0)}'`.pem | sed -n '/Issuer/s/^.*DC=//p'"
end
