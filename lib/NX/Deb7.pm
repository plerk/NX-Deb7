package NX::Deb7;

use strict;
use warnings;
use v5.10;
use Path::Class qw( file dir );
use File::Copy ();
use File::HomeDir;

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

sub copy
{
  my($from, $to) = @_;
  say "copy $from => $to";
  if(-e $to)
  {
    say "  [ file already exists, skipping ]";
  }
  else
  {
    File::Copy::copy(@_)or die "Copy failed: $!"
  }
}

# dzil.config.ini gitconfig nanorc ollisg.cshrc root.cshrc 
# ssh.authorized_keys

sub setup_user
{
  my $class = shift;
  
  my $home = dir( File::HomeDir->my_home );
  my $share = __PACKAGE__->share_dir;
  
  $home->subdir('.ssh')->mkpath(0,0700);
  copy(
    $share->file( qw( config ssh.authorized_keys )),
    $home->file('.ssh', 'authorized_keys')
  );

  $home->subdir('.ccache')->mkpath(0,0700);
  
  $home->subdir('.dzil')->mkpath(0,0700);
  copy(
    $share->file( qw( config dzil.config.ini ) ),
    $home->file( '.dzil', 'config.ini' ),
  );
  
  copy(
    $share->file( qw( config gitconfig )),
    $home->file( '.gitconfig' ),
  );

  copy(
    $share->file( qw( config nanorc )),
    $home->file( '.nanorc' ),
  );
  
  copy(
    $share->file( qw( config ollisg.cshrc )),
    $home->file( '.cshrc' ),
  );
  
}  

1;
