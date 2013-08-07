#!/usr/bin/perl -w

use warnings;
use strict;

use DBI;

use Config::General;

my $START_CODE = ''; #' prxh_START_SNIPPET ';
my $END_CODE = ''; #' prxh_END_SNIPPET ';

#tags from http://www.w3schools.com/tags/default.asp
my $html = '\!\-\-|\!DOCTYPE|a|abbr|acronym|address|applet|area|b|base|basefont|bdo|big|blockquote|body|br|button|caption|center|cite|col|colgroup|dd|del|dfn|dir|div|dl|dt|em|fieldset|font|form|frame|frameset|head|h[1-6]|hr|html|i|iframe|img|input|ins|kbd|label|legend|li|link|map|menu|meta|noframes|noscript|object|ol|optgroup|option|p|param|q|s|samp|script|select|small|span|strike|strong|style|sub|sup|table|tbody|td|textarea|tfoot|th|thead|title|tr|tt|u|ul|var|pre|code';

sub strip_html($);

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'config';
}
die "Config file \'$config_path\' does not exist"
	unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

my $dbh_ref = DBI->connect("dbi:Pg:database=$config{db_name}", '', '', {AutoCommit => 1});

if($config{doc_type} eq 'stackoverflow') {

    #Just going to use the ones we found code elements in
    my $q = q[select id, title, body 
		from posts p, 
			(select cast(du as integer) as du from clt where trust = 0 and kind <> 'variable' group by du) as c 
		where c.du = p.id
	     ];

    my $get_du = $dbh_ref->prepare($q);

    $get_du->execute or die "Can't get doc units from db ", $dbh_ref->errstr;

    #Stackoverflow
    while ( my($du, $title, $content) = $get_du ->fetchrow_array) {

        if(defined $title) {
            $content = $title . ' ' . $content;
        }

        #print "\n\nprocessing du = $du\n";
        print strip_html($content);
        print "\n\n";
        #print "\n\nprocessing du = $du\n";
    }
    
    $get_du->finish;
}

$dbh_ref->disconnect;

sub strip_html($) {

    my ($content) = @_;

    #print "$content\n\n";

    #end of line is uninteresting and would make parsing very complex
    $content =~ s/[\n\r]/ /g;

    #uggh, annoying >< nonsense!
    $content =~ s/\&gt;/>/g;
    $content =~ s/\&lt;/</g;

    #want to keep code snips
    $content =~ s/<pre><code>/$START_CODE/gxms;
    $content =~ s|</code></pre>|$END_CODE|gxms;

    #will eat int etc as generic
    $content =~ s/<\/* ($html) .*?>/ /gxms;

    #kludge: eliminate arrays -- just want type
    $content =~ s/\[\d*\]//g;
    # sharp # is like a dot
    $content =~ s/\s#/ /g;
    $content =~ s/#/./g;
    # :: is like a dot
    $content =~ s/::/./g;

    #print $content, "\n\n";

    return $content;
}


