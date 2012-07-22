#!/usr/bin/perl

use DBI;
use Proc::Background;
use File::Find;
use Config::Tiny;
use URI::Escape;
use File::Path qw(make_path);
my $cfg = Config::Tiny->read('config.ini');

if ($< == 0){
  print "Great, we are root, continuing...\n";
} else {
  print "Please run this script as root!\n";
  exit(0);
}


my $dbh2 = DBI->connect("DBI:mysql:database=podcasts;host=localhost;port=3306",$cfg->{'mysql'}->{'username'},$cfg->{'mysql'}->{'password'}) or die "Unable to connect to podcast db...\n";

# Generate HTML Index & RSS Feed
my $sql = qq{SELECT podcast_id,topic from data order by podcast_id desc};
my $sth = $dbh2->prepare($sql);
$sth->execute();

my $pid;
my $topic;
$sth->bind_columns(undef,\$pid,\$topic);
open (INDEXHTML,">",$cfg->{'produce'}->{'public_path'} . "index.html");
open (INDEXHEAD,"<",$cfg->{'update_website'}->{'template_dir'} . "index_head.html") or die "No html head";
while (<INDEXHEAD>){
  print INDEXHTML $_;
}
close INDEXHEAD;
open (NEWRSSINDEX,">",$cfg->{'produce'}->{'public_path'} . "rss_feed.rss");
open (RSSHEADER,"<",$cfg->{'update_website'}->{'template_dir'} . "rss_head.txt");
while (<RSSHEADER>){
  print NEWRSSINDEX $_;
}
close RSSHEADER;
my $size;
my $count;
my $attachmentcount;

while ($sth->fetch()){
  $count = 0;
  $attachmentcount=0;
  print INDEXHTML "Episode # " .  $pid . " : $topic : <A HREF=\"./mp3s/$pid/" ;
  find(\&printHTMLName,$cfg->{'produce'}->{'public_path'} . "./mp3s/$pid/");
  print INDEXHTML "\">mp3</A> ";
  find(\&checkForPics,$cfg->{'produce'}->{'public_path'} . "pngs/$pid/");
  if ($count == 1){
    print INDEXHTML " : <A HREF=\"./pngs/$pid/\">Screen Shots</A>";
  }
  find(\&attachments,$cfg->{'produce'}->{'public_path'} . "attachments/$pid/");
  if ($attachmentcount == 1){
    print INDEXHTML " : <A HREF=\"./attachments/$pid/\">Attachments</A>";
  }
  my $sql1=qq{SELECT COUNT(*) FROM links where podcast_id = ?};
  my $sth1 = $dbh2->prepare($sql1);
  $sth1->execute($pid);
  my @ary = $sth1->fetchrow_array();
  if ($ary[0] > 0){
    print INDEXHTML " : <A HREF=\"./links/$pid/links.html\">Links</A>";
  } 
  print INDEXHTML "<BR>";
  print NEWRSSINDEX "<item>\n";
  print NEWRSSINDEX "  <title>Episode #" . $pid . "</title>\n";
  my $new_topic = $topic;
  $new_topic = uri_escape($topic);
  $new_topic =~ s/%20/ /g;
  print NEWRSSINDEX "  <description>Episode #" . $pid . " : " . $new_topic . "</description>\n";
  print NEWRSSINDEX "  <enclosure url=\"" . $cfg->{'update_website'}->{'website_url'} . "mp3s/" . $pid . "/";
  find(\&printName,$cfg->{'produce'}->{'public_path'} . "mp3s/$pid/");
  print NEWRSSINDEX "\" length=\"$size\" type=\"audio/mpeg\" />\n";
  print NEWRSSINDEX "</item>\n";
}
print NEWRSSINDEX "</channel>\n";
print NEWRSSINDEX "</rss>";
close NEWRSSINDEX;
print INDEXHTML "<BR></BODY></HTML>";
close INDEXHTML ; 

my $linksql = qq{select distinct(podcast_id) from links};
my $linksth = $dbh2->prepare($linksql);
$linksth->execute();

my $p;
$linksth->bind_columns(undef,\$p);
while ($linksth->fetch()){
  make_path $cfg->{'produce'}->{'public_path'} . "/links/$p/";
  my $sql2=qq{select link from links where podcast_id = ?};
  my $sth2 = $dbh2->prepare($sql2);
  $sth2->execute($p);
  my $link;
  $sth2->bind_columns(undef,\$link);
  open(OUT,">",$cfg->{'produce'}->{'public_path'} . "/links/$p/links.html");
  print OUT "<HTML><BODY>";
  print OUT "Links:<BR><BR>";
  while ($sth2->fetch()){
    print OUT "<A HREF=\"$link\">$link</A><BR><BR>";
  }
  print OUT "</BODY></HTML>";
  close OUT;
}

sub checkForPics{
  my $x = $_;
  next if (-d $x);
  next if ($x =~/index.html/);
  $count = 1;
}
sub attachments{
  my $x = $_;
  next if (-d $x);
  $attachmentcount = 1;
}


sub printName{
  my $fn = $_;
  next if (-d $fn);
  print NEWRSSINDEX $fn ;
  $size = -s $fn;
}
sub printHTMLName{
  my $fn = $_;
  next if (-d $fn);
  print INDEXHTML $fn ;
}

# Set permissions on files...
my $x = Proc::Background->new("/bin/chmod 755 -R " . $cfg->{'produce'}->{'public_path'}  );
$x->wait();

# Sync /public directory to site.

my $z = Proc::Background->new($cfg->{'update_website'}->{'rsync'});
$z->wait(); 

print "Done!\n";
