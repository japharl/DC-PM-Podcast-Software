#!/usr/bin/perl
use HTML::Barcode::Code128;
use Image::Dot;
use DBI;
use Net::VNC;
use URL::Encode qw/url_encode/;
use Proc::Background;
use Config::Tiny;

my $cfg = Config::Tiny->read('config.ini');


use CGI qw/:standard/;

my $source = param("SOURCE"); # Source ID

my $dbh = DBI->connect("DBI:mysql:database=present;host=localhost;port=3306",$cfg->{'mysql'}->{'username'},$cfg->{'mysql'}->{'password'});

my $sql = qq{select barcode_ok from vnc_clients where client_id = ?};
my $sth = $dbh->prepare($sql);
$sth->execute($source);

my @result = $sth->fetchrow_array();

print header;
print "<HTML><BODY>";
print "Results:<BR>";
if ($result[0] ==1){
  print "<B>Not OK</B><BR>";
  print "We were unable to connect to your system.  <BR>";
  print "<UL><LI>Is VNC Running?</LI><LI>Did you enter your password correctly?</LI><LI>Do you have a firewall blocking the connection?</LI><LI>Do you need to accept incoming vnc requests?  (Please disable this. :))</LI></UL>";
  print "When you wish to start again, click <A HREF=\"/cgi-bin/present.pl\">here</A><BR>";
  print "</BODY></HTML>"; 
  exit(0);
}

if ($result[0] == 2){
  print "<B>Not OK</B><BR>";
  print "We were able to connect to your system, but we were unable to scan the barcode which indicates that your system is running succesfully...<BR>";
  print "<UL><LI>Is your VNC software up to date?  (This error is generally fixed with newer versions)</LI><LI>Did you minimize the window before you got a success message?</LI></UL>";
  print "When you wish to start again, click <A HREF=\"/cgi-bin/present.pl\">here</A><BR>";
  print "</BODY></HTML>"; 
  exit(0);
}
if ($result[0] == 3){
  print "<B>Not OK</B><BR>";
  print "We were able to connect to your system initially, but we were unable to connect to your system a second time.  (Each time we capture the screen, we make a new vnc connection to your system.)  Please fix this.<BR>";
  print "When you wish to start again, click <A HREF=\"/cgi-bin/present.pl\">here</A><BR>";
  print "</BODY></HTML>"; 
  exit(0);
}
if ($result[0] == 4){
  print "<B>OK!</B><BR>";
  print "You have been added as a presentor.  You may close this window or navigate to another page...<BR>";
  print "Or click <A HREF=\"/\">here</A> to go back to the main menu of this app.<BR>";
  print "</BODY></HTML>"; 
  exit(0);
}

