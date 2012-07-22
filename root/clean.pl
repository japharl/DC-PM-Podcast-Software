#!/usr/bin/perl

use DBI;
use Config::Tiny;

my $cfg = new Config::Tiny->read('config.ini');

if ($< == 0){
  print "Great, we are root, continuing...\n";
} else {
  print "Please run this script as root!\n";
  exit(0);
}

my $dbh = DBI->connect("DBI:mysql:database=present;host=localhost;port=" . $cfg->{mysql}->{port},$cfg->{mysql}->{username},$cfg->{mysql}->{password}) or die "Unable to connect...\n";
$dbh->do("delete from events");
$dbh->do("delete from active_recording");
$dbh->do("delete from vnc_clients");

print "OK.\n";
