#!/usr/bin/env perl

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

package Acuarela::Color;

use v5.40;
use strict;
use warnings;
use utf8;

# Standard imports
use Convert::Color;
use Math::Round 'round';
use Scalar::Util 'looks_like_number';

# Custom imports
use Acuarela::Utils;

# Custom constants
use constant BRAILLE_PREFIX => 0x2800;  # U+2800 = Braille Pattern Blank

# Module enums
use enum qw(RGB RGBA Hex Braille);  # RGB-like color formats
#use enum qw(CMYK=100 HSL HSV);      # Non-RGB color spaces

class Acuarela::Color::RGBA_8 :isa(Convert::Color::RGB8) {
    field $_alpha :param :reader(alpha);

    method to_braille {
        return sprintf(
            "#[%s%s%s]",
            chr(Acuarela::Color::BRAILLE_PREFIX + $self->red),
            chr(Acuarela::Color::BRAILLE_PREFIX + $self->green),
            chr(Acuarela::Color::BRAILLE_PREFIX + $self->blue),
            chr(Acuarela::Color::BRAILLE_PREFIX + round($self->alpha * 255))
        );
    }
}

1;
