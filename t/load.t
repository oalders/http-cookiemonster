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
ok( $monster->get_cookie('RMID'), "got a single cookie" );

my @names = $monster->cookie_names;
ok @names, "got cookie names";

my $rmid = $monster->get_cookie('RMID');
$rmid->val( 'random' );
is $monster->set_cookie('RMID'), 1, "can set cookie by name";

$rmid->val('even more random');
is $monster->set_cookie($rmid), 1, "can set cookie by object";

done_testing();
