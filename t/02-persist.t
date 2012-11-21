use warnings;
use strict;
use Test::More;
use File::Path;

use CloudPAN { persistence_location => '/tmp/cloudpan/' };

# unload stolen from Class::Unload. Thanks ilmari!

sub unload {
    no strict 'refs';
    my ($class) = @_;

    # Flush inheritance caches
    @{$class . '::ISA'} = ();

    my $symtab = $class.'::';
    # Delete all symbols except other namespaces
    for my $symbol (keys %$symtab) {
        next if $symbol =~ /\A[^:]+::\z/;
        delete $symtab->{$symbol};
    }
    
    my $inc_file = join( '/', split /(?:'|::)/, $class ) . '.pm';
    delete $INC{ $inc_file };
}


{
    package Foo;
    use
        Number::Zero; # Make sure this doesn't show up as a dep
    sub test_me { is_zero(0) }
}

is(Foo::test_me, 1, 'things loaded appropriately');


{
    package Bar;
    BEGIN
    {
        main::unload('Number::Zero');
        require
            Number::Zero;
        Number::Zero->import();
    }
    sub test_me { is_zero(0) }
}

is(Foo::test_me, 1, 'things loaded appropriately from cache');

File::Path::remove_tree('/tmp/cloudpan');

done_testing();

