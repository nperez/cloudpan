package CloudPAN;
use warnings;
use strict;

BEGIN {
    require MetaCPAN::API::Tiny;
    require Symbol;
    use IO::All;
    my $api = MetaCPAN::API::Tiny->new();

    push(@INC, sub {
        my ($self, $name) = @_;

        my $ret = $api->fetch('module/_search', q => qq|path:lib/$name|, size => 1, fields => 'author,release,path' )
            ->{hits}->{hits}->[0]->{fields} or die "Unable to fetch relevant info from MetaCPAN for $name";

        my $req_url = join('/', $api->{base_url}, 'source', @{$ret}{qw/author release path/});
        
        my $content = $api->{ua}->get($req_url)->{content};
        
        my $io = io('/tmp/' . $name);
        $io->assert;
        $io->mode('>');
        $io->print($content);
        $io->close();

        my @file = split(/(?=\n)/, $content)
            or die "Unable to gather the actual source for $name";
        
        my $reader = sub {
            $_ = shift(@file);
            return scalar(@file) > 0 ? 1 : 0;
        };
        
        return Symbol::gensym(), $reader;
    });
}

1;
