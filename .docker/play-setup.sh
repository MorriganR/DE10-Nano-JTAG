#!/usr/bin/expect

set installer [lindex $argv 0]
set installdir [lindex $argv 1]
set timeout 1200

spawn $installer --mode text --installdir $installdir

expect {
  "Do you want to continue to install the software*" { send "y\r"; exp_continue }
  "Press \\\[Enter\\\] to continue:" { send "\r"; exp_continue }
  "Do you accept this license? \\\[y/n\\\]" { send "y\r"; exp_continue }
  "Installation directory \\\[*\\\]" { send "\r"; exp_continue }
  "Quartus Prime Lite Edition (Free)  \\\[Y/n\\\] :" { send "y\r"; exp_continue }
  "Quartus Prime Lite Edition (Free)  - Quartus Prime Help" { send "n\r"; exp_continue }
  "Quartus Prime Lite Edition (Free)  - Devices*" { send "y\r"; exp_continue }
  "ModelSim - Intel FPGA Starter Edition (Free)" { send "n\r"; exp_continue }
  "ModelSim - Intel FPGA Edition" { send "n\r"; exp_continue }
  "Is the selection above correct? \\\[Y/n\\\]:" { send "y\r"; exp_continue }
  "Create shortcuts on Desktop \\\[Y/n\\\]:" { send "n\r"; exp_continue }
  "Launch Quartus Prime Lite Edition \\\[Y/n\\\]:" { send "n\r"; exp_continue }
  "Provide your feedback at*" { send "N\r\n"; sleep 15; exit 0 }
  eof { }
}
