package HTTP::CookieMonster::Cookie;

use Moo;

has 'discard'   => ( is => 'rw', );
has 'domain'    => ( is => 'rw', );
has 'expires'   => ( is => 'rw', );
has 'hash'      => ( is => 'rw', );
has 'key'       => ( is => 'rw', );
has 'path'      => ( is => 'rw', );
has 'path_spec' => ( is => 'rw', );
has 'port'      => ( is => 'rw', );
has 'secure'    => ( is => 'rw', );
has 'val'       => ( is => 'rw', );
has 'version'   => ( is => 'rw', );

1;
