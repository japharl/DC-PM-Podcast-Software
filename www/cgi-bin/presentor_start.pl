#!/usr/bin/perl
use DBI;
use Net::Address::IP::Local;
use URL::Encode qw/url_encode/;


use CGI qw/:standard/;

print header;

my $number = int(rand 1000) + 100;

my $password = param("PASSWORD");
my $host_alias = param("HOST_ALIAS");

print "<HTML><head>";
print "<meta http-equiv=\"refresh\" content=\"30; url=http://" . Net::Address::IP::Local->public_ipv4 . "/cgi-bin/vnc_results.pl?SOURCE=$number\">";
print "<link rel=\"stylesheet\" href=\"/Barcode/barcode.css\" type=\"text/css\">";
print "<script src=\"/Barcode/barcode.js\" type=\"text/javascript\"></script>";

print "</head><BODY onload=\"go();\">";
print "Please wait... <BR>";  
print "Number : $number <BR>";
print "<div class=\"barcode128h\" id=\"barcode\"></div>";
print "<BR>";
print "<script type=\"text/javascript\">";
print "  var strBarcodeHTML = code128('Z' + $number);"; # Darn u javascript
print "  document.getElementById(\"barcode\").innerHTML = strBarcodeHTML;";
print "function go(){";
print "var image = new Image();";
print "image.onload = function() {";
print "window.location=\"http://" . Net::Address::IP::Local->public_ipv4 . "/cgi-bin/vnc_results.pl?SOURCE=$number\";";
print "};";
print " image.src='/cgi-bin/wait_for_vnc.pl?SOURCE=$number&P=" . url_encode($password) . "&HA=" . url_encode($host_alias) . "';";

print "}\n";
print "</script></body></html>";
