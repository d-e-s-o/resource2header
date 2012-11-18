#!/usr/bin/perl -w

#/***************************************************************************
# *   Copyright (C) 2012 Daniel Mueller (deso@posteo.net)                   *
# *                                                                         *
# *   This program is free software: you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation, either version 3 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# *   This program is distributed in the hope that it will be useful,       *
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *   GNU General Public License for more details.                          *
# *                                                                         *
# *   You should have received a copy of the GNU General Public License     *
# *   along with this program.  If not, see <http://www.gnu.org/licenses/>. *
# ***************************************************************************/


use warnings;
use strict;

use File::Basename;
use File::Spec;


my $argc = scalar(@ARGV);

if (!($argc == 1 || $argc == 2))
{
  print "invalid number of arguments\n";
  print "usage: $ARGV[0] <input file> [<output dir>]\n";
  exit -1;
}

my $input = "$ARGV[0]";

if (! -f "$input")
{
  print "invalid file given\n";
  exit -2;
}

open(FILE, $input) or die($!);
binmode(FILE);

my $text   = "";
my $length = 0;
my $data;

while (read(FILE, $data, 1) > 0)
{
  $text   .= ", " if $text ne "";
  $text   .= "0x" . sprintf("%02X", ord($data));
  $length += 1;
}

while ($text =~ s/([^\n]{76}), /  $1,\n/g) {}
$text =~ s/([^\n]{1,76})$/  $1/g;

close(FILE);

# we are only interested in the actual filename, no paths and stuff
my $file = basename($input);

my $temp = lc($file);
   $temp =~ tr/.-/_/;
   $file    = $file     . ".hpp";
my $guard   = uc($temp) . "_HPP";
my $content =    $temp  . "_data";
my $size    =    $temp  . "_size";
my $output  = $file;

if ($argc == 2)
{
  $output = File::Spec->catfile("$ARGV[1]", "$file");
}

open(FILE, ">$output") or die($!);
printf FILE<<EOF;
// $file

#ifndef $guard
#define $guard


unsigned char const ${content}[] = {
$text};

unsigned int const $size = $length;


#endif
EOF

close(FILE);
