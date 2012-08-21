use strict;
use warnings;

package HTTP::CookieMonster;

use Moo;
use Carp qw( croak );
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
    is      => 'rwp',
    lazy    => 1,
    builder => '_build_all_cookies',
    isa     => sub { die "ArrayRef required" if reftype $_[0] ne 'ARRAY' }
);

sub _build_all_cookies {

    my $self = shift;
    @_cookies = ();
    $self->cookie_jar->scan( \&_check_cookies );

    return \@_cookies;

}

sub get_cookie {

    my $self = shift;
    my $name = shift;

    my @cookies = ( );
    foreach my $cookie ( @{ $self->all_cookies } ) {
        if ( $cookie->key eq $name ) {
            return $cookie if !wantarray;
            push @cookies, $cookie;
        }
    }

    return shift @cookies if !wantarray;
    return @cookies;

}

sub set_cookie {

    my $self   = shift;
    my $cookie = shift;

    if ( !$cookie->$_isa( 'HTTP::CookieMonster::Cookie' ) ) {
        croak "$cookie is not a HTTP::CookieMonster::Cookie object";
    }

    my $success = $self->cookie_jar->set_cookie(
        $cookie->version,   $cookie->key,    $cookie->val,
        $cookie->path,      $cookie->domain, $cookie->port,
        $cookie->path_spec, $cookie->secure, $cookie->expires,
        $cookie->discard,   $cookie->hash
    ) ? 1 : 0;

    $self->_set_all_cookies( $self->_build_all_cookies );
    return $success;

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

# ABSTRACT: Easy read/write access to your jar of HTTP::Cookies
#

=pod

=head1 SYNOPSIS

    use HTTP::CookieMonster;
    use WWW::Mechanize;

    my $mech = WWW::Mechanize->new;
    $mech->get( 'http://www.nytimes.com' );

    my $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );
    my $cookie = $monster->get_cookie('RMID');
    print $cookie->val;

=head1 DESCRIPTION

Warning: this is BETA code which is still subject to change.

This module was created because messing around with L<HTTP::Cookies> is
non-trivial.  L<HTTP::Cookies> a very useful module, but using it is not always
as easy and clean as it could be. For instance, if you want to find a
particular cookie, you can just ask for it by name.  Instead, you have to use a
callback:

    $cookie_jar->scan( \&callback )

The callback will be invoked with 11 positional parameters:

    0 version
    1 key
    2 val
    3 path
    4 domain
    5 port
    6 path_spec
    7 secure
    8 expires
    9 discard
    10 hash

That's a lot to remember and it doesn't make for very readable code.

Now, let's say you want to save or update a cookie. Now you're back to the many
positional params yet again:

    $cookie_jar->set_cookie( $version, $key, $val, $path, $domain, $port, $path_spec, $secure, $maxage, $discard, \%rest )

Also not readable. Unless you have an amazing memory, you may find yourself
checking the docs regularly to see if you did, in fact, get all those params in
the correct order etc.

HTTP::CookieMonster gives you a simple interface for getting and setting
cookies. You can fetch an ArrayRef of all your cookies:

    my $all_cookies = $monster->all_cookies;
    foreach my $cookie ( @{ $all_cookies } ) {
        print $cookie->key;
        print $cookie->value;
        print $cookie->secure;
        print $cookie->domain;
        # etc
    }

Or, if you know for a fact exactly what will be in your cookie jar, you can
fetch a cookie by name.

    my $cookie = $monster->get_cookie( 'plack_session' );

This gives you fast access to a cookie without a callback, iterating over a
list etc. It's good for quick hacks and you can dump the cookie quite easily to
inspect it's contents in a highly readable way:

    use Data::Printer;
    p $cookie;

If you want to mangle the cookie before the next request, that's easy too.

    $cookie->val('woohoo');
    $monster->set_cookie( $cookie );
    $mech->get( $url );

Or, add an entirely new cookie to the jar:

    use HTTP::CookieMonster::Cookie;
    my $cookie = HTTP::CookieMonster::Cookie->new
        key       => 'cookie-name',
        val       => 'cookie-val',
        path      => '/',
        domain    => '.somedomain.org',
        path_spec => 1,
        secure    => 0,
        expires   => 1376081877
    );

    $monster->set_cookie( $cookie );
    $mech->get( $url );


=head2 new

new() takes just one required parameter, which is cookie_jar, a valid
L<HTTP::Cookies> object.

    my $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );

=head2 cookie_jar

A reader which returns an L<HTTP::Cookies> object.

=head2 all_cookies

Returns an ArrayRef of all cookies in the cookie jar, represented as
L<HTTP::CookieMonster::Cookie> objects.

=head2 set_cookie( $cookie )

Sets a cookie and updates the cookie jar.  Requires a
L<HTTP::CookieMonster::Cookie> object.

    my $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );
    my $s = $monster->get_cookie('session');
    $s->val('random_string');

    $monster->set_cookie( $s );

    # You can also add an entirely new cookie to the jar via this method

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

=head2 get_cookie( $name )

Be aware that this method may surprise you by what it returns.  When called in
scalar context, get_cookie() returns the first cookie which exactly matches the
name supplied.  In many cases this will be exactly what you want, but that
won't always be the case.

If you are spidering multiple web sites with the same UserAgent object, be
aware that you'll likely have cookies from multiple sites in your cookie jar.
In this case asking for get_cookie('session') in scalar context may not return
the cookie which you were expecting.  You will be safer calling get_cookie() in
list context:

    $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );

    # first cookie with this name
    my $first_session = $monster->get_cookie('session');

    # all cookies with this name
    my @all_sessions  = $monster->get_cookie('session');

=cut
