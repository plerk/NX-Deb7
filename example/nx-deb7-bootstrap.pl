use strict;
use warnings;
use v5.10;
use File::ShareDir::PAR ();
use NX::Deb7;
use Term::Prompt qw( prompt );

say NX::Deb7->share_dir;

if(prompt('y', "dac cave?", '', ''))
{
  say "> nx-deb7-setup-cave";
  NX::Deb7->setup_cave;
}

sub run
{
  say "% @_";
  system(@_);
}

run 'apt-get', 'update';
run 'dpkg', -i => NX::Deb7->share_dir->file(qw( deb libnx-deb7-perl_0.05-1_all.deb ));
run 'apt-get', 'install', '-f';

say "> nx-deb7-setup-root";
NX::Deb7->setup_root;
