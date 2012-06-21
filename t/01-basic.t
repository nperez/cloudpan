use warnings;
use strict;

use Test::More;

BEGIN { use_ok('CloudPAN'); }

{
    package Foo;
    use Moo;

    has bar => (is => 'ro');
    sub baz { $_[0]->bar; }
}

is(Foo->new(bar=>3)->baz, 3, 'things loaded appropriately');

done_testing();

