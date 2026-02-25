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

print("Test Color [OBJECT]\t=\t$test_color\n");
print(Dumper(\%$test_color));

print("${\($test_color->as_braille())}\n");
print("${\($test_color->as_hex())}\n");
print("${\($test_color->as_str())}\n");

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

my $parsed_cmyk= Acuarela::Utils::parse_color("cmyk(1.0, 0.75, 0.5, 0.25)");
print(Dumper(\%$parsed_cmyk));
print("${\($parsed_cmyk->as_str())}\n");
print("${\($parsed_cmyk->as_cmy())}\n");
print("${\($parsed_cmyk->as_braille())}\n");
print("${\($parsed_cmyk->as_hex())}\n");
