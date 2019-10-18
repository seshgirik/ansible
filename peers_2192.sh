#!/bin/bash



#if grep -q FAILED out ;then     wall "correct peer_ips in all scs , remove GM-2192 or MW-2192"; fi




ansible -m  shell -a "\rm out "  scs
ansible -m  shell -a "/opt/confd/confdInstallDir/bin/confd_load -lm /data/fqdn_local.xml "  scs
ansible -m  shell -a "/opt/confd/confdInstallDir/bin/confd_load -Fp -p /sys/platform/peer_ip > peer_ip.xml "  scs
ansible -m  shell -a "egrep \"GM-2192|MW-2192\"  peer_ip.xml "  scs >out
ansible -m  shell -a "if [[ -s out ]] ;then     wall \"correct peer_ips in all scs , remove GM-2192 or MW-2192\"; else echo \"nothing\" ;fi" scs

