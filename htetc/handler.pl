#!/usr/bin/perl
#
# This is a basic, fairly fuctional Mason handler.pl.
#
# For something a little more involved, check out session_handler.pl

package HTML::Mason;

# Bring in main Mason package.
use HTML::Mason;

# Bring in ApacheHandler, necessary for mod_perl integration.
# Uncomment the second line (and comment the first) to use
# Apache::Request instead of CGI.pm to parse arguments.
use HTML::Mason::ApacheHandler;
# use HTML::Mason::ApacheHandler (args_method=>'mod_perl');

# Uncomment the next line if you plan to use the Mason previewer.
#use HTML::Mason::Preview;

use strict;

# List of modules that you want to use from components (see Admin
# manual for details)
#{  package HTML::Mason::Commands;
#   use CGI;
#}

# Create Mason objects
#
my $parser = new HTML::Mason::Parser;
my $interp = new HTML::Mason::Interp (parser=>$parser,
                                      comp_root=>'/var/www/masondocs',
                                      data_dir=>'/home/ivan/freeside_current/masondata',
                                      out_mode=>'stream',
                                     );
my $ah = new HTML::Mason::ApacheHandler (interp=>$interp);

# Activate the following if running httpd as root (the normal case).
# Resets ownership of all files created by Mason at startup.
#
chown (Apache->server->uid, Apache->server->gid, $interp->files_written);

sub handler
{
    my ($r) = @_;

    # If you plan to intermix images in the same directory as
    # components, activate the following to prevent Mason from
    # evaluating image files as components.
    #
    #return -1 if $r->content_type && $r->content_type !~ m|^text/|i;

    #rar
    { package HTML::Mason::Commands;
      use strict;
      use vars qw( $cgi $p );
      use CGI;
      #use CGI::Carp qw(fatalsToBrowser);
      use Date::Format;
      use Date::Parse;
      use Tie::IxHash;
      use HTML::Entities;
      use IO::Handle;
      use IO::File;
      use String::Approx qw(amatch);
      use FS::UID qw(cgisuidsetup dbh getotaker datasrc);
      use FS::Record qw(qsearch qsearchs fields dbdef);
      use FS::Conf;
      use FS::CGI qw(header menubar popurl table itable ntable idiot eidiot
                     small_custview);

      use FS::agent;
      use FS::agent_type;
      use FS::domain_record;
      use FS::cust_bill;
      use FS::cust_bill_pay;
      use FS::cust_credit;
      use FS::cust_credit_bill;
      use FS::cust_main;
      use FS::cust_main_county;
      use FS::cust_pay;
      use FS::cust_pkg;
      use FS::cust_refund;
      use FS::cust_svc;
      use FS::nas;
      use FS::part_bill_event;
      use FS::part_pkg;
      use FS::part_referral;
      use FS::part_svc;
      use FS::pkg_svc;
      use FS::port;
      use FS::queue;
      use FS::raddb;
      use FS::session;
      use FS::svc_acct;
      use FS::svc_acct_pop qw(popselector);
      use FS::svc_acct_sm;
      use FS::svc_domain;
      use FS::svc_forward;
      use FS::svc_www;
      use FS::type_pkgs;

      $cgi = new CGI;
      &cgisuidsetup($cgi);
      #&cgisuidsetup($r);
      $p = popurl(2);
    }
    $r->content_type('text/html');
    #eorar

    my $headers = $r->headers_out;
    $headers->{'Pragma'} = $headers->{'Cache-control'} = 'no-cache';
    #$r->no_cache(1);
    $headers->{'Expires'} = '0';
    
    my $status = $ah->handle_request($r);
    
    return $status;
}

1;
