#!/usr/bin/perl

use File::Path ;
use Proc::Background;
use DBI;
use File::Copy;
use MP3::ID3v1Tag;
use Config::Tiny;
use strict;

if ($< == 0){
  print "Great, we are root, continuing...\n";
} else {
  print "Please run this script as root!\n";
  exit(0);
}


my $cfg = new Config::Tiny->read('config.ini');

mkpath $cfg->{produce}->{temp_directory} ; 

my $data_path = $cfg->{record}->{data_path};

my $dbh = DBI->connect("DBI:mysql:database=present;host=localhost;port=" . $cfg->{mysql}->{port},$cfg->{mysql}->{username},$cfg->{mysql}->{password}) or die "Unable to connect to main db...\n";
my $dbh2 = DBI->connect("DBI:mysql:database=podcasts;host=localhost;port=" . $cfg->{mysql}->{port},$cfg->{mysql}->{username},$cfg->{mysql}->{password}) or die "Unable to connect to podcast db...\n";

my $sql = qq{SELECT epoch_start FROM active_recording};
my $sth = $dbh->prepare($sql);
$sth->execute();
my @ary = $sth->fetchrow_array();
my $epoch = $ary[0];
print "START \n";
if (!( -e $data_path . $epoch . "/audio.wav")){
  print "Audio does not exist.\n";
}
my $x = Proc::Background->new("/bin/cp " . $data_path . $epoch . "/audio.wav " . $data_path . $epoch . "/convert.wav ");
$x->wait(); # Make audio.wav a convert.wav # need to do the directory thing here!

print "Inserting into podcast table...\n";

my $sql = qq{SELECT event_extra FROM events where event_epoch = ?};
my $sth = $dbh->prepare($sql);
$sth->execute($epoch);

my ($topic) = $sth->fetchrow_array();

my $sqlp = qq{INSERT INTO data(epoch_time,topic) values (?,?)};
my $sthp = $dbh2->prepare($sqlp);
$sthp->execute($epoch,$topic);

my $last_id = $dbh2->{'mysql_insertid'};
&writePodcastIntro($last_id,$epoch,$topic);

my $x = Proc::Background->new($cfg->{produce}->{flite_path} . " " . $cfg->{produce}->{temp_directory} . "tmp.txt -o " . $cfg->{produce}->{temp_directory} . "tmp.wav");
$x->wait();

print "Done!\n";
print "Converting...\n";
my $cv = Proc::Background->new($cfg->{produce}->{sox_path} . " " . $cfg->{produce}->{temp_directory} . "tmp.wav " . $cfg->{produce}->{temp_directory} . "tmpconv.wav rate 44.1k");
$cv->wait();

print "Making paths...\n";
mkpath ($cfg->{produce}->{public_path} . "pngs/$last_id/");
mkpath ($cfg->{produce}->{public_path} . "attachments/$last_id/");
mkpath ($cfg->{produce}->{public_path} . "mp3s/$last_id/");
print "Done!\nIdentifying events to edit...";

my $sqlpub = qq {SELECT event_epoch,event_type from events  where event_epoch >= ? order by event_epoch};

my $sthpub = $dbh->prepare($sqlpub);
$sthpub->execute($epoch);
my $ee;
my $et;
my $filestart ;
my $start = 0;
my $stop;
my $part = 0;
my $quited = 0;
$sthpub->bind_columns(undef,\$ee,\$et);
while ($sthpub->fetch()){
  next if ($quited == 1);
  print "event type: $et\n";
  if ($et eq 'START'){
    $filestart = $ee;
    $start = $ee;
  } 
  if ($et eq 'QUIT') {
     $quited=1;
     $part = $part + 1;
     $stop = $ee;
     my $x = $cfg->{'produce'}->{'sox_path'} . " " . $cfg->{'record'}->{'data_path'} . $epoch . "/convert.wav " . $cfg->{'record'}->{'data_path'} . $epoch . "/part" . $part . ".wav trim " . ($start - $filestart) . " " . ($stop-$start) ;
     print "$x\n";
     my $z = Proc::Background->new($x);
     $z->wait();
  }
  if (($et eq 'Screen Capture')){
    copy ($cfg->{'record'}->{'data_path'} . $epoch . "/$ee.png",$cfg->{'produce'}->{'public_path'} . "/pngs/" . $last_id . "/");
  }
}

print "Generating new wav file...\n";
my $zstr = $cfg->{'produce'}->{'sox_path'} . " " . $cfg->{produce}->{temp_directory} . "tmpconv.wav " . $cfg->{'record'}->{'data_path'} . $epoch . "/convert.wav " . $cfg->{'record'}->{'data_path'} . $epoch . "/tmp.wav";
my $z = Proc::Background->new($zstr);
$z->wait();

my $i = 1;
while ($i < $part){
  $i = $i + 1;
  print "Processing Part $i\n";
  my $str = $cfg->{'produce'}->{'sox_path'} . " " . $cfg->{'record'}->{'data_path'} . $epoch ."/tmp.wav " . $cfg->{'record'}->{'data_path'} . $epoch . "/part$i.wav " . $cfg->{'record'}->{'data_path'} . $epoch . "/tmp2.wav";
  $z = Proc::Background->new($str);
  $z->wait();
  move($cfg->{'record'}->{'data_path'} . $epoch . "/tmp2.wav",$cfg->{'record'}->{'data_path'} . $epoch . "/tmp.wav");
}
mkpath ($cfg->{'produce'}->{'public_path'} . "/mp3s/$last_id/");
print "running lame...\n";
my $x = Proc::Background->new($cfg->{'produce'}->{'lame_path'} . " -h " . $cfg->{'record'}->{'data_path'} . $epoch . "/tmp.wav " . $cfg->{'produce'}->{'public_path'} . "mp3s/$last_id/$epoch.mp3");
$x->wait();

my $author = $cfg->{produce}->{author};
my $title = $cfg->{produce}->{title};
$title =~s/\#EPISODENUMBER\#/$last_id/g;
$title =~s/\#TOPIC\#/$topic/g;
my @local = localtime($epoch);
my @abbr = qw( January Febuary March Aprl May June July August September October November December );
my $year = $local[5] + 1900;
$title =~s/\#YEAR\#/$year/g;
my $month = $abbr[$local[4]];
$title =~s/\#MONTH\#/$month/g;


my $z = Proc::Background->new($cfg->{'produce'}->{'mp32info2_path'} . " -t " . $title . " -a " . $author . " -n $last_id " . $cfg->{'produce'}->{'public_path'} . "mp3s/$last_id/$epoch.mp3");
$z->wait();
print "Done!\n";

sub writePodcastIntro{
  my $last_id = shift;
  my $epoch = shift;
  my $topic = shift;

  my @local = localtime($epoch);
  my @abbr = qw( January Febuary March Aprl May June July August September October November December );

  my $start = $cfg->{produce}->{start_string};
  $start =~s/\#EPISODENUMBER\#/$last_id/g;
  $start =~s/\#TOPIC\#/$topic/g;
  my $year = $local[5] + 1900;
  $start =~s/\#YEAR\#/$year/g;
  my $month = $abbr[$local[4]];
  $start =~s/\#MONTH\#/$month/g;


  open (OUT,">",$cfg->{produce}->{temp_directory} . "tmp.txt");
  print OUT $start;
  close OUT;

}
