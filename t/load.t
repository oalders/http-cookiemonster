#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Data::Printer;
use Data::Serializer;
use HTTP::CookieMonster;

my $serializer = Data::Serializer->new;
my $jar = $serializer->retrieve('t/.cookie_jar.txt');

p $jar;

$monster = HTTP::CookieMonster->new( cookie_jar => $jar );
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

done_testing();
