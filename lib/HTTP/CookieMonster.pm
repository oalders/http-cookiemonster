use strict;
use warnings;

package HTTP::CookieMonster;

use Data::Printer;
use Moo;
#use Moose;
use Safe::Isa;

my %_cookies = ( );

has 'cookie_jar' => (
    required => 1,
    is       => 'ro',
    isa      => sub {
        die "HTTP::Cookies object expected"
            if !$_[0]->$_isa( 'HTTP::Cookies' );
    }
);

has 'all_cookies' => ( is => 'lazy', isa => 'HashRef' );

sub _build_all_cookies {

    my $self = shift;
    $self->cookie_jar->scan( \&_check_cookies );
    return \%_cookies;

}

sub cookie {
    my $self = shift;
    my $name = shift;

    return $self->all_cookies->{ $name };

}

sub _check_cookies {
    my @args = @_;
    print "starting to check cookies\n";
    p @args;
    $_cookies{ $args[1] } = {
        version   => $args[0],
        val       => $args[2],
        path      => $args[3],
        domain    => $args[4],
        port      => $args[5],
        path_spec => $args[6],
        secure    => $args[7],
        expires   => $args[8],
        discard   => $args[9],
        hash      => $args[10],
    };
    return;
}

1;
