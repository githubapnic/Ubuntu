#!/usr/bin/expect

# https://corecoding.com/cisco-expect-script_c32.html

set timeout 5
set hostname [lindex $argv 0]
set port [lindex $argv 1]

set username "cisco"
set password "cisco"

spawn telnet $hostname $port

send "\n"

expect "Username:" {
  send "$username\n"
  expect "Password:"
  send "$password\n"

  expect "#" {
    send "conf t\n"
    send "load disk0:SR1-base\n"}
  expect "#" {
    send "commit replace\n"
    send "yes\n"
    send "end\n"
    send "reload\n"}
  expect "confirm]" {
    send "\n"}
  expect "Done]" {
    send "\n"
    send "\r"}

}
