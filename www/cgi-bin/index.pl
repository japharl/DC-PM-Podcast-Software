#!/usr/bin/perl

use CGI qw/:standard/;
use Net::Address::IP::Local;

print header;

print "<HTML><BODY>";
print "DC.PM Podcaster Software<BR><BR>";
print "My IP address is: " . Net::Address::IP::Local->public_ipv4 . "<BR><BR>";

# Check to see if presentation is ready
# If so

print "To add yourself as a presentor, click <A HREF=\"present.pl\">here</A>.<BR>";

print "</BODY></HTML>";




