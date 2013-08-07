#!/usr/bin/perl -w

use warnings;
use strict;

use DBI;

use Config::General;

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'config';
}
die "Config file \'$config_path\' does not exist"
	unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

my $dbh_ref = DBI->connect("dbi:Pg:database=$config{db_name}", '', '', {AutoCommit => 1});

my $get_du = $dbh_ref->prepare(q{select du, pqn, simple, kind from clt where trust = 0 and kind <> 'variable' order by du, pos});

$get_du->execute or die;

my $du_old = '';
while ( my ($du, $pqn, $simple, $kind) = $get_du ->fetchrow_array) {


    if ($du_old ne $du) {
        print "\n\n";
        #test - print "$du \n";
    }
    
    my $ce;

    if ($kind =~ /type/) {
        $ce = $simple;
    }
    else {
        $ce = "$pqn.$simple";
    }

    print "$ce ";

    $du_old = $du;
}

$get_du->finish;
$dbh_ref->disconnect;
