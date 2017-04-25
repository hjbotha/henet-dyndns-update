# henet-dyndns-update

Set the variables in the first section.

HOSTNAME is the FQDN of the AAAA record you're updating.

PASSWORD is the key associated with that record.

DEVICE is the name of the device to get the IP address from. As this is IPv6, there's no facility for getting the IP from an external source.

Run the script using cron. Since it'll only actually communicate with he.net if there's an update, it can be run as frequently as you like.
