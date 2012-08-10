use strict;
use warnings;

package HTTP::CookieMonster;

use Moo;
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

    #my @cookies = @_cookies;
    #@_cookies = ();
    return \@_cookies;

}

sub cookie_names {
    my $self = shift;
    my @names = map { $_->key } @{ $self->all_cookies };
    return @names;
}

sub get_cookie {

    my $self = shift;
    my $name = shift;
    foreach my $cookie ( @{ $self->all_cookies } ) {
        return $cookie if $cookie->key eq $name;
    }
    return;

}

sub update_cookie {

    my $self   = shift;
    my $cookie = $self->get_cookie( shift );

    return $self->cookie_jar->set_cookie(
        $cookie->version,   $cookie->key,    $cookie->val,
        $cookie->path,      $cookie->domain, $cookie->port,
        $cookie->path_spec, $cookie->secure, $cookie->expires,
        $cookie->discard,   $cookie->hash
    );

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
    my $cookie = $monster->get_cookie('RMID');
    print $cookie->val;

=head1 DESCRIPTION

=head2 cookie_jar

=head2 cookie_names

=head2 get_cookie( $name )

=head2 update_cookie( $name )

=cut
