#!/usr/bin/perl

use File::Path ;
use Proc::Background;
use DBI;
use Net::VNC; 
use Config::Tiny;
use Audio::Wav;

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
print "Default topic: " . $cfg->{record}->{topic_default} . "\n";
print "Default topic will be used for the topic unless you change the value below.\n";
print "Enter topic for the inital podcast: ";
my $topic = <STDIN>;
$topic =~ chomp ($topic);

if (length($topic)==0){
  print "Using default topic...\n";
  $topic = $cfg->{record}->{topic_default};
}

my $epoch = time;

my $data_dir = $cfg->{record}->{data_path} . $epoch;
mkpath $data_dir;
my $sql = qq{INSERT into active_recording(epoch_start) value (?)};
my $sth = $dbh->prepare($sql);
$sth->execute($epoch);
&insertEvent($epoch,"START",$topic);

print "File name to add: ";
my $sel = <STDIN>;
$sel =~ chomp ($sel);

my $xaza = new Audio::Wav;
my $read = $xaza->read($sel) or die "Unable to read wav file!\n";

my $len = $read->length_seconds();
print "Ok, len $len ...\n";
system ("cp " . $sel . " " . $data_dir . "/audio.wav");
print "Coppied...\n";

&insertEvent(($epoch + $len),"QUIT");

print "OK.\n";
print "Run produce!\n";

exit(0);

sub insertEvent{
  my $epoch = shift;
  my $event_type = shift;
  my $optional = shift;

  if (length($optional)==0){
  my $esql = qq{INSERT INTO events(event_epoch,event_type) values (?,?)};
  my $esth = $dbh->prepare($esql);
  $esth->execute($epoch,$event_type);
  } else {
  my $esql = qq{INSERT INTO events(event_epoch,event_type,event_extra) values (?,?,?)};
  my $esth = $dbh->prepare($esql);
  $esth->execute($epoch,$event_type,$optional);

  }
}
