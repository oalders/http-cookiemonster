# NAME

HTTP::CookieMonster - Easy read/write access to your jar of HTTP::Cookies

[![Build Status](https://travis-ci.org/oalders/http-cookiemonster.png?branch=master)](https://travis-ci.org/oalders/http-cookiemonster)

# VERSION

version 0.10

# SYNOPSIS

    # Use the functional interface for quick read-only access
    use HTTP::CookieMonster qw( cookies );
    use WWW::Mechanize;

    my $mech = WWW::Mechanize->new;
    my $url = 'http://www.nytimes.com';
    $mech->get( $url );

    my @cookies = cookies( $mech->cookie_jar );
    my $cookie  = cookies( $mech->cookie_jar, 'RMID' );
    print $cookie->val;

    # Use the OO interface for read/write access

    use HTTP::CookieMonster;

    my $monster = HTTP::CookieMonster->new( $mech->cookie_jar );
    my $cookie = $monster->get_cookie('RMID');
    print $cookie->val;

    $cookie->val('random stuff');
    $monster->set_cookie( $cookie );

    # now fetch page using mangled cookie
    $mech->get( $url );

# DESCRIPTION

This module was created because messing around with [HTTP::Cookies](https://metacpan.org/pod/HTTP%3A%3ACookies) is
non-trivial.  [HTTP::Cookies](https://metacpan.org/pod/HTTP%3A%3ACookies) a very useful module, but using it is not always
as easy and clean as it could be. For instance, if you want to find a
particular cookie, you can't just ask for it by name.  Instead, you have to use
a callback:

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
cookies. You can fetch an ARRAY of all your cookies:

    my @all_cookies = $monster->all_cookies;
    foreach my $cookie ( @all_cookies ) {
        print $cookie->key;
        print $cookie->val;
        print $cookie->secure;
        print $cookie->domain;
        # etc
    }

Or, if you know for a fact exactly what will be in your cookie jar, you can
fetch a cookie by name.

    my $cookie = $monster->get_cookie( 'plack_session' );

This gives you fast access to a cookie without a callback, iterating over a
list etc. It's good for quick hacks and you can dump the cookie quite easily to
inspect its contents in a highly readable way:

    use Data::Printer;
    p $cookie;

If you want to mangle the cookie before the next request, that's easy too.

    $cookie->val('woohoo');
    $monster->set_cookie( $cookie );
    $mech->get( $url );

Or, add an entirely new cookie to the jar:

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
    $mech->get( $url );

## new

new() takes just one required parameter, which is cookie\_jar, a valid
[HTTP::Cookies](https://metacpan.org/pod/HTTP%3A%3ACookies) object.

    my $monster = HTTP::CookieMonster->new( $mech->cookie_jar );

## cookie\_jar

A reader which returns an [HTTP::Cookies](https://metacpan.org/pod/HTTP%3A%3ACookies) object.

## all\_cookies

Returns an ARRAY of all cookies in the cookie jar, represented as
[HTTP::CookieMonster::Cookie](https://metacpan.org/pod/HTTP%3A%3ACookieMonster%3A%3ACookie) objects.

    my @cookies = $monster->all_cookies;
    foreach my $cookie ( @cookies ) {
        print $cookie->key;
    }

## set\_cookie( $cookie )

Sets a cookie and updates the cookie jar.  Requires a
[HTTP::CookieMonster::Cookie](https://metacpan.org/pod/HTTP%3A%3ACookieMonster%3A%3ACookie) object.

    my $monster = HTTP::CookieMonster->new( $mech->cookie_jar );
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

## delete\_cookie( $cookie )

Deletes a cookie and updates the cookie jar.  Requires a
[HTTP::CookieMonster::Cookie](https://metacpan.org/pod/HTTP%3A%3ACookieMonster%3A%3ACookie) object.

## get\_cookie( $name )

Be aware that this method may surprise you by what it returns.  When called in
scalar context, get\_cookie() returns the first cookie which exactly matches the
name supplied.  In many cases this will be exactly what you want, but that
won't always be the case.

If you are spidering multiple web sites with the same UserAgent object, be
aware that you'll likely have cookies from multiple sites in your cookie jar.
In this case asking for get\_cookie('session') in scalar context may not return
the cookie which you were expecting.  You will be safer calling get\_cookie() in
list context:

    $monster = HTTP::CookieMonster->new( $mech->cookie_jar );

    # first cookie with this name
    my $first_session = $monster->get_cookie('session');

    # all cookies with this name
    my @all_sessions  = $monster->get_cookie('session');

# FUNCTIONAL/PROCEDURAL INTERFACE

## cookies

This function will DWIM.  Here are some examples:

    use HTTP::CookieMonster qw( cookies );

    # get all cookies in your jar
    my @cookies = cookies( $mech->cookie_jar );

    # get all cookies of a certain name/key
    my @session_cookies = cookies( $mech->cookie_jar, 'session_cookie_name' );

    # get the first cookie of a certain name/key
    my $first_session_cookie = cookies( $mech->cookie_jar, 'session_cookie_name' );

# AUTHOR

Olaf Alders <olaf@wundercounter.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Olaf Alders.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
