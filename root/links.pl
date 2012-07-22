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

my $dbh = DBI->connect("DBI:mysql:database=podcasts;host=localhost;port=" . $cfg->{mysql}->{port},$cfg->{mysql}->{username},$cfg->{mysql}->{password}) or die "Unable to connect...\n";

print "Menu:\n";
print "1. Add link.\n";
print "2. Remove Link.\n";
print "Q. (Or anything other than 1 or 2): Quit\n";
print "Selection: ";
my $in = <STDIN>;
$in =~ chomp ($in);
if ($in eq '1'){
  print "\n\nFor what podcast number?  Selection:";
  my $podin = <STDIN>;
  $podin =~ chomp($podin);

  print "\nLink: ";
  my $linkin = <STDIN>;
  $linkin =~ chomp($linkin); 

  my $sql2=qq{INSERT INTO links (podcast_id,link) values (?,?)};
  my $sth2 = $dbh->prepare($sql2);
  $sth2->execute($podin,$linkin);
  print "Done!\n";
  exit(0);
}
if ($in eq '2'){
  my $sql3=qq{Select podcast_id,link,link_id from links order by link_id};
  my $sth3 = $dbh->prepare($sql3);
  $sth3->execute();
  my $pod_id;
  my $link;
  my $link_id;
  $sth3->bind_columns(undef,\$pod_id,\$link,\$link_id);
  my $i=0;
  while ($sth3->fetch()){
    print "Link ID: $link_id \tLink: $link \tPodcast id: $pod_id\n";
    $i = $i + 1;
  }
  if ($i > 1){
    print "Link ID From Above: ";
    my $x = <STDIN>;
    $x =~ chomp($x);
    my $sql4=qq{DELETE FROM links where link_id = ?};
    my $sth4 = $dbh->prepare($sql4);
    $sth4->execute($x);
    print "OK.\n";
    exit(0);
  } else {
    print "Nothing to delete...\n";
    exit(0);
  }
}
print "Exiting...\n";
exit(0);
