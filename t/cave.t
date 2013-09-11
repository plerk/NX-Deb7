use strict;
use warnings;
use Test::More tests => 3;
use File::Temp qw( tempdir );
use Path::Class qw( file dir );
use Test::File;
use NX::Deb7;

my $file = file( tempdir( CLEANUP => 1 ), 'etc', 'apt', 'sources.list' );

$file->parent->mkpath(0,0700);

ok(-d $file->parent, "path $file");

$file->spew(do { local $/; <DATA> });

note 'BEFORE:';
note $file->slurp;

$> = 0;
NX::Deb7->setup_cave($file);

note 'AFTER:';
note $file->slurp;

my $content = $file->slurp;

unlike $content, qr{ftp\.us\.debian\.org}, "does not contain ftp.us.debian.org";
like $content, qr{apt.sydney.wdlabs.com}, "does contain apt.sydney.wdlabs.com";

__DATA__
# 

# deb cdrom:[Debian GNU/Linux 7.0.0 _Wheezy_ - Official amd64 NETINST Binary-1 20130504-14:43]/ wheezy main

#deb cdrom:[Debian GNU/Linux 7.0.0 _Wheezy_ - Official amd64 NETINST Binary-1 20130504-14:43]/ wheezy main

deb http://ftp.us.debian.org/debian/ wheezy main
deb-src http://ftp.us.debian.org/debian/ wheezy main

deb http://security.debian.org/ wheezy/updates main
deb-src http://security.debian.org/ wheezy/updates main

# wheezy-updates, previously known as 'volatile'
deb http://ftp.us.debian.org/debian/ wheezy-updates main
deb-src http://ftp.us.debian.org/debian/ wheezy-updates main

