package NX::Deb7;

use strict;
use warnings;
use v5.10;
use Path::Class qw( file dir );
use File::Copy ();
use File::HomeDir;
use File::ShareDir qw( dist_dir );

# ABSTRACT: Graham's environment for Debian 7
# VERSION

sub share_dir
{
  state $path;
  
  unless(defined $path)
  {
    if(defined $NX::Deb7::VERSION && $INC{'NX/Deb7.pm'} =~ /blib/)
    {
      $path = Path::Class::File
        ->new($INC{'NX/Deb7.pm'})
        ->absolute
        ->dir
        ->parent
        ->parent
        ->parent
        ->subdir('share');
        undef $path unless $path && -d $path;
    }

    eval { 
      if(defined $NX::Deb7::VERSION && ! defined $path)
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

sub run
{
  say "% @_";
  system @_;
}

sub setup_root
{
  my($class) = @_;
  
  if($>)
  {
    print "must be run as root\n";
    exit 2;
  }
  
  my $home = dir( File::HomeDir->my_home );
  my $share = __PACKAGE__->share_dir;
  
  my $user = 'ollisg';
  do {
    my $found = 0;
    while(my @user = getpwent)
    {
      $found = 1 if $user[0] eq 'ollisg';
    }
    unless($found)
    {
      run 'adduser', '--gecos' => 'Graham THE Ollis', 'ollisg';
    }
  };
  
  run 'adduser', 'ollisg', 'sudo';
  run 'dpkg', '-i', $share->subdir('debs')->children;
  run 'apt-get', 'install', '-f';

  copy(
    $share->file( qw( config root.cshrc )),
    $home->file( '.cshrc' ),
  );
  
  run 'chsh', 'ollisg', '-s', '/bin/tcsh';
  run 'chsh', 'root', '-s', '/bin/tcsh';
}

sub setup_cave
{
  my($class, $file) = @_;
  
  $file //= file( '/etc/apt/sources.list' );

  unless(-w $file)
  {
    print "must be run as root\n";
    exit 2;
  }
  
  my $content = $file->slurp;
  
  $content =~ s{http://security\.debian\.org/}{http://apt.sydney.wdlabs.com:3142/security.debian.org/}g;
  $content =~ s{http://ftp\...\.debian\.org/debian/}{http://apt.sydney.wdlabs.com:3142/debian/}g;
  
  $file->spew($content);
}

1;
