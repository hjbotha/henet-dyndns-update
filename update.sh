#! /bin/bash
#set -x

HOSTNAME=host.name.of.ddns.AAAA.record
PASSWORD=key_specific_to_the_host_you_are_updating
DEVICE=eth0

OLDIP=$(cat /tmp/dyndns.oldip)
if [ $? -eq 0 ]; then
  logger "Old IP is $OLDIP"
else
  logger "Old IP could not be determined. Assuming first run."
  #OLDIP=$(sipcalc :: | grep Expanded | awk '{print $4}')
fi

NEWIP=$(ip -6 addr list $DEVICE | grep global | grep -v deprecated | grep -v "inet6 f" | awk '{print $2}')
  if [ $? -ne 0 ]; then
  logger "New IP address could not be determined. Do you have a public ipv6 IP? Exiting."
  exit 1
else
  NEWIP=$(sipcalc $NEWIP | grep Expanded | awk '{print $4}')
  logger "New IP is $NEWIP"
fi

URL="http://dyn.dns.he.net/nic/update"

if [ "$NEWIP" != "$OLDIP" ]; then 
  logger "IP changed from $OLDIP to $NEWIP. Updating HE.net."
  RESULT=placeholderstring
  RESULT=$(curl -s $URL -d "hostname=$HOSTNAME" -d "password=$PASSWORD" -d "myip=$NEWIP")
  logger "HE.net responded: $RESULT"
  if [[ $RESULT =~ .*(good|nochg).* ]]; then
    echo $NEWIP > /tmp/dyndns.oldip
    logger "Success!"
  else
    logger "Update failed. What did HE.net respond with?"
  fi
else
  logger "IP address hasn't changed, stop bugging me."
fi
