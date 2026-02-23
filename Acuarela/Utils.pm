#!/usr/bin/env perl

package Acuarela::Utils;

use v5.40;
use strict;
use warnings;

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
use Acuarela::Color::RGBA;

# Module utility functions
sub parse_color($color_str) {   # Mainly to be able to use Acuarela::Color classes given any color string passed to STDIN
    # Generate a color object given the current color space
    if ($color_str =~ m/(?:(rgb)a?)?(\(?(\d{1,3},?\s?){3,4}\)?)/gi) { # RGBA color string

        # [TODO]: Add the following regex patterns to this section:
        #   --> /(?:#\[?)((\d|[abcdef]){2}){3,4}(?:]?)/gi   # Hex color strings
        #   --> /(?:#\[?)([⠀-⣿]){3,4}(?:]?)/gu              # Braille color strings (values between U+2800 - U+28FF)

        # Extract each channel accordingly
        my @dummy_capture = split(/,\s?|\(|\)/, $2);
        shift(@dummy_capture);

        my @rgba_capture = map {int($_)} @dummy_capture;

        # Build the RGBA color object
        my $depth = (max(@rgba_capture) <= 255)? 8 : 16;

        return Acuarela::Color::RGBA->new(
            "channels"  => {
                'r' => $rgba_capture[0],
                'g' => $rgba_capture[1],
                'b' => $rgba_capture[2],
                'a' => (defined($rgba_capture[3]))? $rgba_capture[3] : 255,
            },
            "bit_depth" => $depth,
        );
    }
    else {
        croak("Couldn't determine the current color space from the color string \'$color_str\'");
    }
}

1;
