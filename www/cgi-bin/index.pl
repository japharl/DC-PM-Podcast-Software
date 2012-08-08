#!/usr/bin/perl

use CGI qw/:standard/;
use Net::Address::IP::Local;

my $ip = Net::Address::IP::Local->public_ipv4
  or qq|<span style="color:red">Could not detect IP!</span>|;

print header;
print <<EOHTML;
<html>
  <body>
    <p>DC.PM Podcaster Software</p>
    <p>"My IP address is: $ip</p>
    <p>To add yourself as a presentor, click <a href="present.pl">here</a>.</p>
  </body>
</html>
EOHTML
