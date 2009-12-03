#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'MediaWiki::FastDump' );
}

diag( "Testing MediaWiki::FastDump $MediaWiki::FastDump::VERSION, Perl $], $^X" );
