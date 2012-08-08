#!/usr/bin/perl

use CGI qw/:standard/;

# FIXME there's no reason why this couldn't be a static page, but that would require renaming
# this file and moving it outside of the cgi-bin directory and updating everything that links to it.
# so. yeah. 

print header;
print <<EOHTML;
<html>
  <body>
    <p>Thank you for being a presenter.</p>
    <p>Pleae make sure VNC is installed as a service on your computer.</p>
    <p style="color:red;font-weight:bold">PLEASE NOTE:</p>
    <p>Your screen will be captured through the course of your presentation.  This may be shared over the podcast.  Please refrain from sharing personal information you do not wish to have publically available during this time.</p>
    <p>You acknowledge by proceeding that you have read this disclaimer.</p>
    <p></p>
    <p>Once you hit submit, you will see a barcode on your screen while we test to ensure that VNC has been set up correctly on your computer.</p>
    <p>Do <strong>not</strong> minimize the window while the barcode is displayed.</p>";
    <p>You will see an OK message once your machine has been verified, with a PC number that we will use to access your screen.  Please be sure that Zak knows this number... :)</p>
    <form method="POST" action="presentor_start.pl">
      <p>Optional - VNC Password: <input type="password" name="PASSWORD" />
      <br />
      <p>
        Your name / Machine name (eg. Brock's PC or Brock's Phone): 
        <input type="text"   name="HOST_ALIAS" /><br />
        <input type="submit" name="Submit" value="Submit" />
      </p>
    </form>
  </body>
</html>
EOHTML


