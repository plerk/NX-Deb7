use strict;
use warnings;
use Test::More tests => 2;
use NX::Deb7;

my $dir = eval { NX::Deb7->share_dir };
diag $@ if $@;

ok defined $dir, "dir defined";
ok -d $dir, "dir exists $dir";
