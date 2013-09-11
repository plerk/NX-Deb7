use strict;
use warnings;
use v5.10;
use File::ShareDir::PAR ();
use NX::Deb7;
use Term::Prompt qw( prompt );

say NX::Deb7->share_dir;

if(prompt('y', "dac cave?", '', ''))
{
  say "nx-deb7-setup-cave";
  NX::Deb7->setup_cave;
}

say "nx-deb7-setup-root";
NX::Deb7->setup_root;
