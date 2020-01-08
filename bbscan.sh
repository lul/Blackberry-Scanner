#!/bin/bash

sys_check()
{
  if [ -e "/usr/share/nmap" ]; then
    if [ -e "/usr/share/nmap/scripts/nmap-vulners" ]; then
      return
    else
    echo "'nmap-vulners' not installed. Run 'sudo git clone https://github.com/vulnersCom/nmap-vulners.git' from within '/usr/share/nmap/scripts/'"
    exit
    fi
  else
    echo "nmap not found. Run 'sudo apt install nmap' from within your terminal."
    exit 
  fi
}

self_discover() 
{
  iplist="ip addr | grep 'state UP' -A2 | grep 'inet' | awk '{print \$2}' | tail -n1 | cut -f1 -d '/' | cut -d '.' -f1,2,3"
  eval $iplist 
}

ping_all()
{
  ping -c 1 $1 > /dev/null
  [ $? -eq 0 ] && echo $i
}

enumerate()
{
  for i in $(self_discover).{1..254}
  do
    ping_all $i & disown
  done
}

ipscan()
{
  for i in $(enumerate)
  do
    nmap -p 1-65535 $i 
  done
}

vulnscan()
{
  for i in $(enumerate)
  do
    nmap -sV --script nmap-vulners -p1-65535 $i
  done
}

menu()
{
  echo "What would you like to do? 
        1: Enumerate all IP's on network
        2: Discover ports & services on all IP's
        3: Vulnerability Scan all IP's
        4: Exit"
  read minput
  if [ $minput -lt 1 ] || [ $minput -gt 4 ]; then
    echo -e "Invalid input.\n"
    menu
  else
  case $minput in
    "1") echo -e "$(enumerate)\n"; menu;;
    "2") echo -e "$(ipscan)\n"; menu;;
    "3") echo -e "$(vulnscan)\n"; menu;;
    "4") exit
  esac
  fi
}

sys_check
menu
