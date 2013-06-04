package NX::Deb7;

use strict;
use warnings;
use v5.10;
use Path::Class::Dir;
use Path::Class::File;

# ABSTRACT: Graham's environment for Debian 7
# VERSION

sub share_dir
{
  state $path;
  
  unless(defined $path)
  {
    eval { 
      if(defined $NX::Deb7::VERSION)
      {
        $path = Path::Class::Dir
          ->new(dist_dir('NX-Deb7'));
      }
      undef $path unless $path && -d $path;
    };

    unless(defined $path)    
    {
      $path = Path::Class::File
        ->new($INC{'NX/Deb7.pm'})
        ->absolute
        ->dir
        ->parent
        ->parent
        ->subdir('share');
    }
    die 'can not find share directory' unless $path && -d $path;
  }
  
  $path;
}

1;
