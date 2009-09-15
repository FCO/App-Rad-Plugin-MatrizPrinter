#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Rad::Plugin::MatrizPrinter' );
}

diag( "Testing App::Rad::Plugin::MatrizPrinter $App::Rad::Plugin::MatrizPrinter::VERSION, Perl $], $^X" );
