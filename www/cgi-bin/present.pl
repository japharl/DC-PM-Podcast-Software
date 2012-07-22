#!/usr/bin/perl

use CGI qw/:standard/;
use Net::Address::IP::Local;

print header;

print "<HTML><BODY>";
print "Thank you for being a presenter.<BR>";
print "Pleae make sure VNC is installed as a service on your computer.<BR>";
print "<B><FONT COLOR=\"RED\">PLEASE NOTE</FONT>:";
print "Your screen will be captured through the course of your presentation.  This may be shared over the podcast.  Please refrain from sharing personal information you do not wish to have publically available during this time.<BR>";
print "You acknowledge by proceeding that you have read this disclaimer.<BR></B>";
print "<BR><BR>";
print "Once you hit submit, you will see a barcode on your screen while we test to ensure that VNC has been set up correctly on your computer.<BR>";
print "Do <b>not</b> minimize the window while the barcode is displayed.<BR>";
print "You will see an OK message once your machine has been verified, with a PC number that we will use to access your screen.  Please be sure that Zak knows this number... :)<BR>";
print "<FORM METHOD=\"post\" action=\"presentor_start.pl\">";
print "Optional - VNC Password: <INPUT TYPE=\"PASSWORD\" NAME=\"PASSWORD\"><BR>";
print "Your name / Machine name (eg. Brock's PC or Brock's Phone): <INPUT TYPE=\"TEXT\" NAME=\"HOST_ALIAS\"><BR><BR>";
print "<INPUT TYPE=\"submit\" NAME=\"Submit\" VALUE=\"Submit\"><BR>";
print "</BODY></HTML>";

