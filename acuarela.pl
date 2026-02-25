#!/usr/bin/env perl
use v5.40;

use strict;
use warnings;
use diagnostics;
use utf8;
use utf8::all;

# Main Testbench
use Data::Dumper;
use Moose;
use Term::ANSIColor;

# Make all of Acuarela's modules visible
use FindBin qw($RealBin);
use lib ($RealBin, "$RealBin/Acuarela");

# Custom imports
use Acuarela::Color::RGBA;
use Acuarela::Utils;

# Script testing
my $test_color = Acuarela::Color::RGBA->new(
    "channels"  => {'r' => 0, 'g' => 200, 'b' => 200, 'a' => 255},
    #"bit_depth" => 16,
);

my @test_spaces = qw(CMY CMYK HSL HSV RGB RGBA);
my @lc_spaces = map {lc($_)} @test_spaces;

print("Test Color [OBJECT]\t=\t$test_color\n");
print(Dumper(\%$test_color));

print("${\($test_color->as_braille())}\n");
print("${\($test_color->as_hex())}\n");
print("${\($test_color->as_str())}\n");

print(Dumper(@test_spaces));
print(Dumper(@lc_spaces));

foreach(@lc_spaces) {
    my $test_str = $test_color->convert_to($_);
    print("Test color conversion: $test_str\n");
}

#print(Term::ANSIColor::color)

$test_color->update_channels(('r' => 255, 'g' => 128));
print(Dumper(\%$test_color));

my $parsed_color = Acuarela::Utils::parse_color($test_color->as_str());
print(Dumper(\%$parsed_color));

$test_color->update_channels(('a' => 64));
my $parsed_braille = Acuarela::Utils::parse_color($test_color->as_braille());
print(Dumper(\%$parsed_braille));

$test_color->update_channels(('b' => 64));
my $parsed_hex = Acuarela::Utils::parse_color($test_color->as_hex());
print(Dumper(\%$parsed_hex));

my $parsed_web = Acuarela::Utils::parse_color("#09f");
print(Dumper(\%$parsed_web));
