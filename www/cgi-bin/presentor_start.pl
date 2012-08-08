#!/usr/bin/perl

use CGI qw/:standard/;
use DBI;
use Net::Address::IP::Local;
use URL::Encode qw/url_encode/;

my $number = int(rand 1000) + 100;
my $ip     = Net::Address::IP::Local->public_ipv4;

my $password   = url_encode(param("PASSWORD"));
my $host_alias = url_encode(param("HOST_ALIAS"));

print header;
print <<EOHTML;
<html>
  <head>
    <meta http-equiv="refresh" content="30; url=http://$ip/cgi-bin/vnc_results.pl?SOURCE=$number" />
    <link rel="stylesheet" href="/Barcode/barcode.css" type="text/css">
    <script src="/Barcode/barcode.js" type="text/javascript"></script>
  </head>
  <body onload="go();">
    <p>Please wait...<br/> Number: $number </p>
    <div class="barcode128h" id="barcode"></div>
    <br/>
    <script type="text/javascript">
      var strBarcodeHTML = code128('Z' + $number);
      document.getElementById("barcode").innerHTML = strBarcodeHTML;
      function go(){
        var image = new Image();
        image.onload = function() {
          window.location="http://$ip/cgi-bin/vnc_results.pl?SOURCE=$number\";
        };
        image.src='/cgi-bin/wait_for_vnc.pl?SOURCE=$number&P=$password&HA=$host_alias';
      }
    </script>
  </body>
</html>
EOHTML