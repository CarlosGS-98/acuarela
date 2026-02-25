#!/usr/bin/env perl

package Acuarela::Utils;

use v5.40;
use strict;
use warnings;
use utf8;
use utf8::all;

# Make this module exportable
use Exporter "import";

our @EXPORT_OK = qw(:all);
our $VERSION = '0.01';

# Standard imports
use Carp;
use Convert::Color;
use Convert::Color::CMY;
use Convert::Color::CMYK;
use Convert::Color::HSL;
use Convert::Color::HSV;
use Convert::Color::RGB;
use Convert::Color::RGB8;
use Convert::Color::RGB16;
use List::Util qw(max min);
use Term::ANSIColor;

# Custom imports
use Acuarela::Color;
use Acuarela::Color::CMYK;
use Acuarela::Color::RGBA;

# Module utility functions
sub parse_color($color_str) {   # Mainly to be able to use Acuarela::Color classes given any color string passed to STDIN
    # Generate a color object given the current color space
    if ($color_str =~ m/(?:#\[?)([\x{2800}-\x{28FF}]{3,4})(?:]?)/gu) {          # Braille color string
        # Extract each channel accordingly
        my ($red_br, $green_br, $blue_br)   = map {$_ - Acuarela::Color::BRAILLE_PREFIX} (ord(substr($1, 0, 1)), ord(substr($1, 1, 1)), ord(substr($1, 2, 1)));
        my $alpha_br                        = (length($1) == 4)? ord(substr($1, 3, 1)) - Acuarela::Color::BRAILLE_PREFIX : 255;

        # Build an RGBA color object
        return Acuarela::Color::RGBA->new(
            "channels"  => {
                'r' => $red_br,
                'g' => $green_br,
                'b' => $blue_br,
                'a' => $alpha_br,
            },
            "bit_depth" => 8,   # It's a pretty sensible assumption given that the "Braille Patterns" Unicode block occupies 256 characters
        );
    }
    elsif ($color_str =~ m/(?:(cmy)k?)((\(?\d(\.\d+)?(,\s?)?\)?){3,4})/gi) {    # CMYK color string
        # Extract each channel accordingly
        my @dummy_capture = split(/,\s?|\(|\)/, $2);
        shift(@dummy_capture);

        # Build a CMYK color object
        return Acuarela::Color::CMYK->new(
            "channels"  => {
                'c' => $dummy_capture[0] + 0.0, # To coerce our values into floats
                'm' => $dummy_capture[1] + 0.0,
                'y' => $dummy_capture[2] + 0.0,
                'k' => (defined($dummy_capture[3]))? $dummy_capture[3] + 0.0 : 0.0,
            },
        );
    }
    elsif ($color_str =~ m/(?:#\[?)((([\d|[abcdef]){1,2}){3,4})(?:]?)/gi) {     # Hex color string
        my ($red_hex, $green_hex, $blue_hex, $alpha_hex); # Since we're gonna fill each channel depending on how many hex digits the string has

        if (length($1) == 3) {                              # Web-safe color string (without alpha)
            # Expand each channel from a single nibble to a byte (i. e., 'f' -> 'ff')
            ($red_hex, $green_hex, $blue_hex)   = map {$_ * 17} (hex(substr($1, 0, 1)), hex(substr($1, 1, 1)), hex(substr($1, 2, 1)));
            $alpha_hex                          = 255;  # By default
        }
        elsif ((length($1) == 6) || (length($1) == 8)) {    # Regular hex color string (with(out) alpha)
            ($red_hex, $green_hex, $blue_hex)   = (hex(substr($1, 0, 2)), hex(substr($1, 2, 2)), hex(substr($1, 4, 2)));
            $alpha_hex                          = (length($1) == 8)? hex(substr($1, 6, 2)) : 255;
        }
        else {
            croak("Badly formatted hex color string \'$color_str\' (Length = ${length($1)})");
        }

        # Build an RGBA color object
        return Acuarela::Color::RGBA->new(
            "channels"  => {
                'r' => $red_hex,
                'g' => $green_hex,
                'b' => $blue_hex,
                'a' => $alpha_hex,
            },
            "bit_depth" => 8,   # Support for 16-bit-per-channel hex colors might be added in the future
        );
    }
    elsif ($color_str =~ m/(?:(rgb)a?)?(\(?(\d{1,3},?\s?){3,4}\)?)/gi) {        # RGBA color string
        # Extract each channel accordingly
        my @dummy_capture = split(/,\s?|\(|\)/, $2);
        shift(@dummy_capture);

        my @rgba_capture = map {int($_)} @dummy_capture;

        # Build an RGBA color object
        my $depth = (max(@rgba_capture) <= 255)? 8 : 16;

        return Acuarela::Color::RGBA->new(
            "channels"  => {
                'r' => $rgba_capture[0],
                'g' => $rgba_capture[1],
                'b' => $rgba_capture[2],
                'a' => (defined($rgba_capture[3]))? $rgba_capture[3] : 2 ** $depth - 1,
            },
            "bit_depth" => $depth,
        );
    }
    else {
        croak("Couldn't determine the current color space from the color string \'$color_str\'");
    }
}

1;
