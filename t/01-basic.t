use warnings;
use strict;

use Test::More;

BEGIN { use_ok('CloudPAN'); }

{
    package Foo;
    use
        Number::Zero; # Make sure this doesn't show up as a dep
    sub test_me { is_zero(0) }
}

is(Foo::test_me, 1, 'things loaded appropriately');

done_testing();

