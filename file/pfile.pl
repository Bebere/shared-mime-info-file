#!/usr/bin/perl

use warnings;
use strict;
use 5.010;

use Fcntl ':mode';
use Scalar::Util;
use Getopt::Long;
use File::MimeInfo::Magic;

Getopt::Long::Configure( "no_ignorecase" );

my @files = ("\0");
my %opts;
my $follow_symlink = 1;
my $restricted_tests = 0;

sub extended_file_test {
  my $file = $_[0];
  foreach my $handlfile(@files) {
    say "File treated: $file";
    if ($handlfile ne "\0") {
      say "Rehash time on $handlfile!";
    }
    my $desc = File::MimeInfo::Magic::describe(File::MimeInfo::Magic::mimetype($file));
    say "$file: $desc";
  }
}

sub handler_default {
  say "Add default files";
  push @files, "\0";
}

sub handler_just_magic {
  my ($opt_name, $opt_value) = @_;
  say "Option name is $opt_name and value is $opt_value";
  push @files, $opt_value;
}

sub handler_magic {
  handler_just_magic(@_);
  handler_default();
}

sub ident_symlink {
  say "Identify symlinks as symlinks";
  $follow_symlink = 0;
}

sub restrict_tests {
  say "Restricting file tests";
  $restricted_tests = 1;
}

GetOptions(\%opts, 
           "i" => \&restrict_tests,
           "h" => \&ident_symlink,
           "d" => \&handler_default,
           "m=s" => \&handler_just_magic,
           "M=s" => \&handler_magic);

say @files;
foreach my $file(@ARGV) {
  my $desc;
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = $follow_symlink ? stat($file) : lstat($file);
  if (S_ISREG($mode))
  {
    $desc = "regular file";
  }
  elsif (S_ISDIR($mode))
  {
    $desc = "directory";
  }
  elsif (S_ISLNK($mode))
  {
    my $target = readlink($file);
    $desc = "symbolic link to $target";
  }
  elsif (S_ISBLK($mode))
  {
    $desc = "block special";
  }
  elsif (S_ISCHR($mode))
  {
    $desc = "character special";
  }
  elsif (S_ISCHR($mode))
  {
    $desc = "character special";
  }
  elsif (S_ISFIFO($mode))
  {
    $desc = "fifo";
  }
  elsif (S_ISSOCK($mode))
  {
    $desc = "socket";
  }
  else
  {
    $desc = "unknown";
  }
  say "$file: $desc";
}
say "Cousin Willie!";
