#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;

use Fcntl ':mode';
use File::Temp 'tempdir';
use Scalar::Util;
use Getopt::Long;
use File::MimeInfo::Magic;
use XML::LibXML;

Getopt::Long::Configure( "no_ignorecase" );

my @files = ("\0");
my %opts;
my $follow_symlink = 1;
my $restricted_tests = 0;
my $dataset_change = 0;

sub parse_magic {
  my $file = $_[0];
  my @res = ();
  my $lastline = undef;
  open (my $fh, '<', $file);
  while (<$fh>) {
    chomp;
    my ($offset, $type, $value, $message) = split("\t");
    say "Offset: $offset";
    say "Type: $type";
    say "Valeur: $value";
    say "Message: $message";
    say "---------";
    my $line = [$offset, $type, $value, $message, ()];
    my $ind = index($offset, '>');
    if($ind == 0)
    {
      $line->[0] = substr($offset, 1);
      if(defined($lastline))
      {
        push @{ $lastline->[4] }, $line;
      }
      else
      {
        die "Bad magic file (a magic file's first line's offset shouldn't start with >).";
      }
      say "Offset': $line->[0]";
      say "Type': $line->[1]";
      say "Valeur': $line->[2]";
      say "Message': $line->[3]";
      say "---------";
    }
    elsif($ind == -1)
    {
      $lastline = $line;
      push @res, $line
    }
    else
    {
      die "Bad magic file (if present, > should be the offset's first character).";
    }
  }
  close ($fh);
  return @res;
}

sub create_temp_mime_files {
  my @tests = @_;
  my $tmpdir = tempdir(CLEANUP => 1);
  my $document = XML::LibXML::Document->createDocument();
  return $tmpdir;
}

sub extended_file_test {
  my ($file, $size) = @_;
  if(!$size) {
    return "empty file";
  }
  my $mime = File::MimeInfo::Magic::mimetype($file);
  if(defined($mime))
  {
    my $desc = File::MimeInfo::Magic::describe($mime);
    if($desc =~ /script/ and $desc !~ /shell script/) {
      $desc =~ s/(script)/$1, executable text/;
    }
    $desc =~ s/(shell script)/$1 \(commands text\)/;
    $desc =~ s/(\b?.+\b?) source code/$1 program text/;
    return $desc;
  }
  else
  {
    return "unknown data";
  }
}

sub handler_default {
  push @files, "\0";
}

sub handler_just_magic {
  my ($opt_name, $opt_value) = @_;
  say "Option name is $opt_name and value is $opt_value";
  my @AoA = parse_magic($opt_value);
  for my $i ( 0 .. $#AoA ) {
        for my $j ( 0 .. $#{$AoA[$i]} ) {
            say "elt $i $j is $AoA[$i][$j]";
        }
    }
  my $tempdir = create_temp_mime_files(@AoA);
  say "Dir: $tempdir";
  push @files, $opt_value;
}

sub handler_magic {
  handler_just_magic(@_);
  handler_default();
}

sub ident_symlink {
  $follow_symlink = 0;
}

sub restrict_tests {
  $restricted_tests = 1;
}

GetOptions(\%opts, 
           "i" => \&restrict_tests,
           "h" => \&ident_symlink,
           "d" => \&handler_default,
           "m=s" => \&handler_just_magic,
           "M=s" => \&handler_magic);

foreach my $file(@ARGV) {
  my $desc;
  if (-e $file)
  {
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = $follow_symlink ? stat($file) : lstat($file);
   if (S_ISREG($mode))
   {
     if ($restricted_tests)
     {
       $desc = "regular file";
     }
     else
     {
       $desc = extended_file_test($file, $size)
     }
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
  }
  else
  {
    $desc = "cannot open";  
  }
  say "$file: $desc";
}
