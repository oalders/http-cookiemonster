use strict;
use warnings;

package HTTP::CookieMonster;

use Moo;
use Carp;
use Data::Printer;
use HTTP::CookieMonster::Cookie;
use Safe::Isa;

my @_cookies = ();

has 'cookie_jar' => (
    required => 1,
    is       => 'ro',
    isa      => sub {
        die "HTTP::Cookies object expected"
            if !$_[0]->$_isa( 'HTTP::Cookies' );
        }

);

has 'all_cookies' => ( is => 'lazy', isa => 'ArrayRef' );

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
    print "starting to check cookies\n";

    #p @args;

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

=head2 cookie_jar

=head2 all_cookies

=head2 feeling_lucky( $name )

=head2 set_cookie( $name|HTTP::CookieMonster::Cookie )

Sets the cookie (updates the cookie jar).  Accepts either the name (key) of a
cookie or an HTTP::CookieMonster::Cooke object.

    my $monster = HTTP::CookieMonster->new( cookie_jar => $mech->cookie_jar );
    my $s = $monster->feeling_lucky('session');
    $s->val('random_string');

    $monster->set_cookie( 'session');
    # or by cookie object
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

=cut
