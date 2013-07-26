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

    #instead of old query above which modifies stackoverflow tables, we union the parents and the children (parents don't have a parentid) 
#    my $get_du = $dbh_ref->prepare(qq[
#                  select parentid, id, title, body, msg_date from                                                                                                                                                              
#                  (select id as parentid, id, title, body, to_timestamp(creationdate) as msg_date from posts 
#                    where id in (select id from posts where tags ~ E'lucene') --the parents                                                                
#                  union select parentid, id, title, body, to_timestamp(creationdate) as msg_date from posts 
#                    where parentid in (select id from posts where tags ~ E'lucene') --the children                                                    
#                    ) as r 
#                  order by parentid, msg_date asc
#                  ]);
#


    #test -#                  select parentid, id, title, body, to_timestamp(creationdate) as msg_date from posts where id = '2083588'];

    #lucene is implemented in all kinds of languages, so need complex regexp
    my $q = q[
                  select parentid, id, title, body, msg_date from 
                  (select id as parentid, id, title, body, to_timestamp(creationdate) as msg_date from posts 
                    where id in (select id from posts where tags ~ E'lucene' and (tags ~ E'java' or tags !~ E'net|c#|php|nhibernate|zend|clucene|ruby|c\\\\+\\\\+|pylucene|python|rails')) 
                  union select parentid, id, title, body, to_timestamp(creationdate) as msg_date from posts 
                    where parentid in (select id from posts where tags ~ E'lucene' and (tags ~ E'java' or tags !~ E'net|c#|php|nhibernate|zend|clucene|ruby|c\\\\+\\\\+|pylucene|python|rails')) 
                    ) as r 
                  order by parentid, msg_date asc
                  ];

    my $get_du = $dbh_ref->prepare($q);

    $get_du->execute or die "Can't get doc units from db ", $dbh_ref->errstr;

    #Stackoverflow
    while ( my($tid, $du, $title, $content) = $get_du ->fetchrow_array) {

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


