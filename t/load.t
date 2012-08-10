#!/usr/bin/env perl

use Test::More;

use Data::Printer;
use HTTP::CookieMonster;
use HTTP::Cookies;
use WWW::Mechanize;

my $cookies = HTTP::Cookies->new;
my $monster = HTTP::CookieMonster->new( cookie_jar => $cookies );

my $mech = WWW::Mechanize->new;
$mech->get( 'http://www.nytimes.com' );

$monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );
ok( $monster,              "got a monster" );
ok( $monster->all_cookies, "all cookies" );
ok( $monster->feeling_lucky('RMID'), "got a single cookie" );

my $rmid = $monster->feeling_lucky('RMID');
$rmid->val( 'random' );
is $monster->set_cookie($rmid), 1, "can set cookie";

# try adding a new cookie to the jar

my $cookie = HTTP::CookieMonster::Cookie->new(
    version   => 0,
    key       => 'foo',
    val       => 'bar',
    path      => '/',
    domain    => '.metacpan.org',
    port      => 80,
    path_spec => 1,
    secure    => 1,
    expires   => 1376081877,
    discard   => undef,
    hash      => {},
);

$monster->set_cookie( $cookie );

diag p $monster->cookie_jar;

done_testing();
