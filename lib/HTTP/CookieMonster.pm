use strict;
use warnings;

package HTTP::CookieMonster;

use Moo;
use Carp;
use Data::Printer;
use HTTP::Cookies;
use HTTP::CookieMonster::Cookie;
use Safe::Isa;
use Scalar::Util qw( reftype );

my @_cookies = ();

has 'cookie_jar' => (
    required => 1,
    is       => 'ro',
    isa      => sub {
        die "HTTP::Cookies object expected"
            if !$_[0]->$_isa( 'HTTP::Cookies' );
        }

);

has 'all_cookies' => (
    is  => 'lazy',
    isa => sub { die "ArrayRef required" if reftype $_[0] ne 'ARRAY' }
);

sub _build_all_cookies {

    my $self = shift;
    $self->cookie_jar->scan( \&_check_cookies );

    return \@_cookies;

}

sub feeling_lucky {

    my $self = shift;
    my $name = shift;
    foreach my $cookie ( @{ $self->all_cookies } ) {
        return $cookie if $cookie->key eq $name;
    }
    return;

}

sub set_cookie {

    my $self   = shift;
    my $cookie = shift;

    if ( !$cookie->$_isa( 'HTTP::CookieMonster::Cookie' ) ) {
        croak "$cookie is not a HTTP::CookieMonster::Cookie object";
    }

    return $self->cookie_jar->set_cookie(
        $cookie->version,   $cookie->key,    $cookie->val,
        $cookie->path,      $cookie->domain, $cookie->port,
        $cookie->path_spec, $cookie->secure, $cookie->expires,
        $cookie->discard,   $cookie->hash
    ) ? 1 : 0;

}

sub _check_cookies {

    my @args = @_;

    push @_cookies,
        HTTP::CookieMonster::Cookie->new(
        version   => $args[0],
        key       => $args[1],
        val       => $args[2],
        path      => $args[3],
        domain    => $args[4],
        port      => $args[5],
        path_spec => $args[6],
        secure    => $args[7],
        expires   => $args[8],
        discard   => $args[9],
        hash      => $args[10],
        );

    return;
}

1;

# ABSTRACT: Easily Read and Update your Jar of HTTP::Cookies
#

=pod

=head1 SYNOPSIS

    use HTTP::CookieMonster;
    use WWW::Mechanize;

    my $mech = WWW::Mechanize->new;
    $mech->get( 'http://www.nytimes.com' );

    my $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );
    my $cookie = $monster->feeling_lucky('RMID');
    print $cookie->val;

=head1 DESCRIPTION

=head2 new

new() takes just one required parameter, which is cookie_jar, a valid
L<HTTP::Cookies> object.  See below for sample code.

    my $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );

=head2 cookie_jar

An L<HTTP::Cookies> object. You would typically get this via:

    my $ua = LWP::UserAgent->new;
    $ua->cookie_jar

    # or via WWW::Mechanize (which inherits from LWP::UserAgent)

    my $mech = WWW::Mechanize->new;
    $mech->cookie_jar;

=head2 all_cookies

Returns an ArrayRef of all cookies in the cookie jar, represented as
L<HTTP::CookieMonster::Cookie> objects.

=head2 set_cookie( $cookie )

Sets the cookie (updates the cookie jar).  Requires a
L<HTTP::CookieMonster::Cookie> object.

    my $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );
    my $s = $monster->feeling_lucky('session');
    $s->val('random_string');

    $monster->set_cookie( $s );

    # You can add an entirely new cookie to the jar via this method
    use HTTP::CookieMonster::Cookie;
    my $cookie = HTTP::CookieMonster::Cookie->new(
        key       => 'cookie-name',
        val       => 'cookie-val',
        path      => '/',
        domain    => '.somedomain.org',
        path_spec => 1,
        secure    => 0,
        expires   => 1376081877
    );

    $monster->set_cookie( $cookie );

=head2 feeling_lucky( $name )

Be aware that this method may surprise you by what it returns.  feeling_lucky()
iterates over the cookies in all_cookies() and returns the first cookie which
exactly matches the name supplied.  In many cases this will be exactly what you
want, but that won't always be the case.  If you are spidering multiple web
sites with the same UserAgent object, be aware that you'll likely have cookies
from multiple sites in your cookie jar.  In this case asking for
feeling_lucky('session') may not return the cookie which you were expecting.

However, if you're running some tests against your own site or just crawling
one specific site and you are confident that only one cookie with this name
exists, feeling_lucky will save you a few lines of code.  It's mostly meant as
a quick hack for when you want to check a cookie in a hurry and have a
reasonable amount of confidence that there are no duplicate cookies in the jar
with this name.

    my $mech = WWW::Mechanize->new;
    $mech->get( 'http://www.nytimes.com' );

    $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );
    my $rmid = $monster->feeling_lucky('RMID');

=cut
