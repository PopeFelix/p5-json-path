# NAME

JSON::Path

# VERSION

version 1.0.3

# SYNOPSIS

    my $data = {
     "store" => {
       "book" => [
         { "category" =>  "reference",
           "author"   =>  "Nigel Rees",
           "title"    =>  "Sayings of the Century",
           "price"    =>  8.95,
         },
         { "category" =>  "fiction",
           "author"   =>  "Evelyn Waugh",
           "title"    =>  "Sword of Honour",
           "price"    =>  12.99,
         },
         { "category" =>  "fiction",
           "author"   =>  "Herman Melville",
           "title"    =>  "Moby Dick",
           "isbn"     =>  "0-553-21311-3",
           "price"    =>  8.99,
         },
         { "category" =>  "fiction",
           "author"   =>  "J. R. R. Tolkien",
           "title"    =>  "The Lord of the Rings",
           "isbn"     =>  "0-395-19395-8",
           "price"    =>  22.99,
         },
       ],
       "bicycle" => [
         { "color" => "red",
           "price" => 19.95,
         },
       ],
     },
    };

    use JSON::Path 'jpath_map';

    # All books in the store
    my $jpath   = JSON::Path->new('$.store.book[*]');
    my @books   = $jpath->values($data);

    # The author of the last (by order) book
    my $jpath   = JSON::Path->new('$..book[-1:].author');
    my $tolkien = $jpath->value($data);

    # Convert all authors to uppercase
    jpath_map { uc $_ } $data, '$.store.book[*].author';

# DESCRIPTION

This module implements JSONPath, an XPath-like language for searching
JSON-like structures.

JSONPath is described at [http://goessner.net/articles/JsonPath/](http://goessner.net/articles/JsonPath/).

## Constructor

- `JSON::Path->new($string)`

    Given a JSONPath expression $string, returns a JSON::Path object.

## Methods

- `values($object)`

    Evaluates the JSONPath expression against an object. The object $object
    can be either a nested Perl hashref/arrayref structure, or a JSON string
    capable of being decoded by JSON::MaybeXS::decode\_json.

    Returns a list of structures from within $object which match against the
    JSONPath expression. In scalar context, returns the number of matches.

- `value($object)`

    Like `values`, but returns just the first value. This method is an lvalue
    sub, which means you can assign to it:

        my $person = { name => "Robert" };
        my $path = JSON::Path->new('$.name');
        $path->value($person) = "Bob";

    TAKE NOTE! This will create keys in $object. E.G.:

        my $obj = { foo => 'bar' };
        my $path = JSON::Path->new('$.baz');
        $path->value($obj) = 'bak'; # $obj->{baz} is created and set to 'bak';

- `paths($object)`

    As per `values` but instead of returning structures which match the
    expression, returns canonical JSONPaths that point towards those structures.

- `get($object)`

    In list context, identical to `values`, but in scalar context returns
    the first result.

- `set($object, $value, $limit)`

    Alters `$object`, setting the paths to `$value`. If set, then
    `$limit` limits the number of changes made.

    TAKE NOTE! This will create keys in $object. E.G.:

        my $obj = { foo => 'bar' };
        my $path = JSON::Path->new('$.baz');
        $path->set($obj, 'bak'); # $obj->{baz} is created and set to 'bak'

    Returns the number of changes made.

- `map($object, $coderef)`

    Conceptually similar to Perl's `map` keyword. Executes the coderef
    (in scalar context!) for each match of the path within the object,
    and sets a new value from the coderef's return value. Within the
    coderef, `$_` may be used to access the old value, and `$.`
    may be used to access the curent canonical JSONPath.

- `to_string`

    Returns the original JSONPath expression as a string.

    This method is usually not needed, as the JSON::Path should automatically
    stringify itself as appropriate. i.e. the following works:

        my $jpath = JSON::Path->new('$.store.book[*].author');
        print "I'm looking for: " . $jpath . "\n";

## Functions

The following functions are available for export, but are not exported
by default:

- `jpath($object, $path_string)`

    Shortcut for `JSON::Path->new($path_string)->values($object)`.

- `jpath1($object, $path_string)`

    Shortcut for `JSON::Path->new($path_string)->value($object)`.
    Like `value`, it can be used as an lvalue.

- `jpath_map { CODE } $object, $path_string`

    Shortcut for `JSON::Path->new($path_string)->map($object, $code)`.

# NAME

JSON::Path - search nested hashref/arrayref structures using JSONPath

# PERL SPECIFICS

JSONPath is intended as a cross-programming-language method of
searching nested object structures. There are however, some things
you need to think about when using JSONPath in Perl...

## JSONPath Embedded Perl Expressions

JSONPath expressions may contain subexpressions that are evaluated
using the native host language. e.g.

    $..book[?($_->{author} =~ /tolkien/i)]

The stuff between "?(" and ")" is a Perl expression that must return
a boolean, used to filter results. As arbitrary Perl may be used, this
is clearly quite dangerous unless used in a controlled environment.
Thus, it's disabled by default. To enable, set:

    $JSON::Path::Safe = 0;

There are some differences between the JSONPath spec and this
implementation.

- JSONPath uses a variable '$' to refer to the root node.
This is not a legal variable name in Perl, so '$root' is used
instead.
- JSONPath uses a variable '@' to refer to the current node.
This is not a legal variable name in Perl, so '$\_' is used
instead.

## Blessed Objects

Blessed objects are generally treated as atomic values; JSON::Path
will not follow paths inside them. The exception to this rule are blessed
objects where:

    Scalar::Util::blessed($object)
    && $object->can('typeof')
    && $object->typeof =~ /^(ARRAY|HASH)$/

which are treated as an unblessed arrayref or hashref appropriately.

# BUGS

Please report any bugs to [http://rt.cpan.org/](http://rt.cpan.org/).

# SEE ALSO

Specification: [http://goessner.net/articles/JsonPath/](http://goessner.net/articles/JsonPath/).

Implementations in PHP, Javascript and C#:
[http://code.google.com/p/jsonpath/](http://code.google.com/p/jsonpath/).

Jayway JsonPath:
[https://github.com/json-path/JsonPath](https://github.com/json-path/JsonPath).


Related modules: [JSON](https://metacpan.org/pod/JSON), [JSON::JOM](https://metacpan.org/pod/JSON%3A%3AJOM), [JSON::T](https://metacpan.org/pod/JSON%3A%3AT), [JSON::GRDDL](https://metacpan.org/pod/JSON%3A%3AGRDDL),
[JSON::Hyper](https://metacpan.org/pod/JSON%3A%3AHyper), [JSON::Schema](https://metacpan.org/pod/JSON%3A%3ASchema).

Similar functionality: [Data::Path](https://metacpan.org/pod/Data%3A%3APath), [Data::DPath](https://metacpan.org/pod/Data%3A%3ADPath), [Data::SPath](https://metacpan.org/pod/Data%3A%3ASPath),
[Hash::Path](https://metacpan.org/pod/Hash%3A%3APath), [Path::Resolver::Resolver::Hash](https://metacpan.org/pod/Path%3A%3AResolver%3A%3AResolver%3A%3AHash), [Data::Nested](https://metacpan.org/pod/Data%3A%3ANested),
[Data::Hierarchy](https://metacpan.org/pod/Data%3A%3AHierarchy)... yes, the idea's not especially new. What's different
is that JSON::Path uses a vaguely standardised syntax with implementations
in at least three other programming languages.

# AUTHOR

Kit Peters https://github.com/popefelix

# CONTRIBUTORS

Toby Inkster https://github.com/tobyink

Szymon Nieznański https://github.com/s-nez

Kit Peters https://github.com/popefelix

Heiko Jansen https://github.com/heikojansen

Mitsuhiro Nakamura https://github.com/mnacamura

David Escribano García https://github.com/DavidEGx

Thomas Helsel https://github.com/thelsel

Patrick Cronin https://github.com/PatrickCronin 

James Bowery https://github.com/jabowery

Slaven Rezić https://github.com/eserte

Max Laager https://github.com/mlaagerc2c

# COPYRIGHT AND LICENSE

Copyright 2007 Stefan Goessner.

Copyright 2010-2013 Toby Inkster.

This software is copyright (c) 2021 by Kit Peters.

This module is tri-licensed. It is available under the X11 (a.k.a. MIT) licence; you can also redistribute it and/or modify it under the same terms as Perl itself.

## a.k.a. "The MIT Licence"

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
