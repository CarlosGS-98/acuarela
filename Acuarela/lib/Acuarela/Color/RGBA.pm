#!/usr/bin/env perl

package Acuarela::Color::RGBA;

use v5.40;

use strict;
use warnings;
use utf8;
use feature 'signatures';

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

# Class definition
use Moose;
use namespace::autoclean;
extends('Acuarela::Color::BaseColor');

# Class constants
use constant BRAILLE_PREFIX => 0x2800;

# Class attributes
has("bit_depth" => (
    'is'        => 'ro',
    'writer'    => '_set_depth',
    'isa'       => 'Int'
));

# Constructor hooks
sub BUILD {
    my $self = shift;
    #print("$self\n");

    # Let's assume by default we have 8 bits per channel
    unless (defined($self->bit_depth)) {
        $self->_set_depth(8);
    }

    # Bit depth can only be 8 or 16 bits at this moment
    croak("Unsupported bit depth (got " . $self->bit_depth . " bits per channel)\n")
        unless (($self->bit_depth == 8) || ($self->bit_depth == 16));

    $self->_set_lower_bound(0);
    $self->_set_upper_bound(2 ** $self->bit_depth - 1);

    # Check whether all corresponding channels exist.
    #
    # If some of the RGBA channels aren't present,
    # then they'll be set to 0 as a default;
    # otherwise, their values should be clamped between [0, 2 ** $_bits].

    unless (defined($self->channels->{'r'})) {
        $self->update_channels(('r' => 0));
    }
    else {
        my $color_val = ($self->channels->{'r'} < $self->min_color_val)? $self->min_color_val : $self->channels->{'r'};
        $color_val = ($self->channels->{'r'} > $self->max_color_val)? $self->max_color_val : $self->channels->{'r'};

        $self->update_channels(('r' => $color_val));
    }

    unless (defined($self->channels->{'g'})) {
        $self->update_channels(('g' => 0));
    }
    else {
        my $color_val = ($self->channels->{'g'} < $self->min_color_val)? $self->min_color_val : $self->channels->{'g'};
        $color_val = ($self->channels->{'g'} > $self->max_color_val)? $self->max_color_val : $self->channels->{'g'};

        $self->update_channels(('g' => $color_val));
    }

    unless (defined($self->channels->{'b'})) {
        $self->update_channels(('b' => 0));
    }
    else {
        my $color_val = ($self->channels->{'b'} < $self->min_color_val)? $self->min_color_val : $self->channels->{'b'};
        $color_val = ($self->channels->{'b'} > $self->max_color_val)? $self->max_color_val : $self->channels->{'b'};

        $self->update_channels(('b' => $color_val));
    }

    unless (defined($self->channels->{'a'})) {
        $self->update_channels(('a' => 0));
    }
    else {
        my $color_val = ($self->channels->{'a'} < $self->min_color_val)? $self->min_color_val : $self->channels->{'a'};
        $color_val = ($self->channels->{'a'} > $self->max_color_val)? $self->max_color_val : $self->channels->{'a'};

        $self->update_channels(('a' => $color_val));
    }
}

override convert_to => sub {
    my $self = shift;
    my $color_space = shift;

    # Create a dummy hash reference to facilitate color conversions
    my $dummy_color = ($self->bit_depth == 8)?
    Convert::Color::RGB8->new($self->channels->{'r'}, $self->channels->{'g'}, $self->channels->{'b'})
    : Convert::Color::RGB16->new($self->channels->{'r'}, $self->channels->{'g'}, $self->channels->{'b'});

    # We should return the string representation of each conversion.
    #
    # Also, whenever possible, these strings should be formatted
    # in the same way as the "Convert::Color" module does.

    if ($color_space =~ m/BRAILLE/i) {  # Hex color but with braille dot patterns
        return sprintf(
                "#[%s%s%s%s]",
                chr(BRAILLE_PREFIX + $self->channels->{'r'}),
                chr(BRAILLE_PREFIX + $self->channels->{'g'}),
                chr(BRAILLE_PREFIX + $self->channels->{'b'}),
                chr(BRAILLE_PREFIX + $self->channels->{'a'})
            );
    }
    elsif ($color_space =~ m/CMYK/i) {
        my ($cyan, $magenta, $yellow, $key) =  $dummy_color->convert_to('cmyk')->cmyk;
        
        return "cmyk:$cyan,$magenta,$yellow,$key";
    }
    elsif ($color_space =~ m/CMY/i) {
        my ($cyan, $magenta, $yellow) =  $dummy_color->convert_to('cmy')->cmy;
        
        return "cmy:$cyan,$magenta,$yellow";
    }
    elsif ($color_space =~ m/HEX/i) {
        return '#' . $dummy_color->hex . sprintf("%2x", $self->channels->{'a'});
    }
    elsif ($color_space =~ m/HSL/i) {
        my ($hue, $sat, $light) =  $dummy_color->convert_to('hsl')->hsl;
        
        return "hsl:$hue,$sat,$light";
    }
    elsif ($color_space =~ m/HSV/i) {
        my ($hue, $sat, $value) =  $dummy_color->convert_to('hsv')->hsv;
        
        return "hsv:$hue,$sat,$value";
    }
    else {
        croak("Unsupported color conversion (tried to convert ${$self->bit_depth}-bit RGBA to \'$color_space\')\n");
    }
};

__PACKAGE__->meta->make_immutable;
