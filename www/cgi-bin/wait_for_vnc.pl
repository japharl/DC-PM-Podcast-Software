#!/usr/bin/perl
use HTML::Barcode::Code128;
use Image::Dot;
use DBI;
use Net::VNC;
use URL::Encode qw/url_encode/;
use Proc::Background;
use Config::Tiny;
use CGI qw/:standard/;

my $cfg = Config::Tiny->read('config.ini');

my $source = param("SOURCE"); # Source ID
my $host_alias = param("HA");
my $password = param("P");
my $remote_ip = $ENV{REMOTE_ADDR};

my $dbh = DBI->connect("DBI:mysql:database=present;host=localhost;port=3306",$cfg->{'mysql'}->{'username'},$cfg->{'mysql'}->{'password'});

my $vnc ;
eval{
  $vnc = Net::VNC->new({hostname=>$remote_ip,password=>$password});
  $vnc->login();
  my $img = $vnc->capture;
  $img->save("/tmp/img_$source.png");
  undef $vnc;
};
if ($@){
  # Error caught
  &doInsert(1);
}

my $proc = Proc::Background->new("/usr/bin/zbarimg --raw /tmp/img_" . $source . ".png > /tmp/img_" . $source . "_result.txt");
$proc->wait();

open (IN,"<","/tmp/img_" . $source . "_result.txt");
my $line;
while (<IN>){
  $line = $_;
  $line =~ chomp ($line);
}
close IN;
my $test = 'Z' . $source;
if ($line eq $test){
  eval{
    $vnc = Net::VNC->new({hostname=>$remote_ip,password=>$password});
    $vnc->login();
    my $img = $vnc->capture;
    $img->save("/tmp/img_$source.png");
  };
  my $a = $@;
  if ($a){
    &doInsert(3);
  } else {
    &doInsert(4);
  }
} else {
  &doInsert(2);
}

sub doInsert{
  my $ok = shift;
  my $sql = qq{INSERT INTO vnc_clients(client_id,password,barcode_ok,host_alias,ip) values (?,?,?,?,?)};
  my $sth = $dbh->prepare($sql);
  $sth->execute($source,$password,$ok,$host_alias,$remote_ip);
  print header(type=>'image/png');
  my $reddot = dot_PNG_RGB(255, 0, 0);
  print $reddot;
  exit(0);
}

