#!/bin/bash
echo "Shutting down Mikrotik Firewall"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o CheckHostIP=no -p 22 -i /etc/nut/id_rsa ups@X.X.X.X "/system shutdown; /y; /quit;"
exit 0
fi