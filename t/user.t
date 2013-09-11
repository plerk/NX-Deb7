use strict;
use warnings;
use File::HomeDir::Test;
use File::HomeDir;
use Test::More tests => 8;
use Test::File;
use Test::Dir;
use Path::Class qw( dir file );
use NX::Deb7;
use Capture::Tiny qw( capture );

my $out = capture sub { NX::Deb7->setup_user };
chomp $out;
note $out;

my $home = dir( File::HomeDir->my_home );

dir_exists_ok     $home->subdir('.ccache');
dir_exists_ok     $home->subdir('.ssh');
file_not_empty_ok $home->file('.ssh', 'authorized_keys');
dir_exists_ok     $home->subdir('.dzil');
file_not_empty_ok $home->file('.dzil', 'config.ini');
file_not_empty_ok $home->file('.gitconfig');
file_not_empty_ok $home->file('.nanorc');
file_not_empty_ok $home->file('.cshrc');
