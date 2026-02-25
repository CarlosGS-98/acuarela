#!/usr/bin/env perl

package Acuarela::Color::CMYK;

use v5.40;

use strict;
use warnings;
use utf8;
use utf8::all;
use feature 'signatures';

# Standard imports
use Carp;
use Convert::Color;
use Convert::Color::CMY;
use Convert::Color::CMYK;

# Class definition
use Moose;
use namespace::autoclean;
extends('Acuarela::Color');

# Class attributes
# (...)

# Constructor hooks
sub BUILD {
    my $self = shift;

    # Assume all color channels lie inside the range [0.0, 1.0]
    $self->_set_lower_bound(0.0);
    $self->_set_upper_bound(1.0);

    # Check whether all corresponding channels exist.
    #
    # If some of the CMYK channels aren't present,
    # then they'll be set to 0 as a default
    # (except the key channel, which will be set then to 1.0
    # to at least set pitch black as its default value).
    #
    # If they are indeed present, their values should be clamped
    # then between [0.0, 1.0].

    # Cyan channel
    unless (defined($self->channels->{'c'})) {
        $self->update_channels(('c' => 0.0));
    }
    else {
        $self->update_channels(('c' => $self->min_color_val)) if ($self->channels->{'c'} <= $self->min_color_val);
        $self->update_channels(('c' => $self->max_color_val)) if ($self->channels->{'c'} >= $self->max_color_val);
        $self->update_channels(('c' => $self->channels->{'c'}));
    }

    # Magenta channel
    unless (defined($self->channels->{'m'})) {
        $self->update_channels(('m' => 0.0));
    }
    else {
        $self->update_channels(('m' => $self->min_color_val)) if ($self->channels->{'m'} <= $self->min_color_val);
        $self->update_channels(('m' => $self->max_color_val)) if ($self->channels->{'m'} >= $self->max_color_val);
        $self->update_channels(('m' => $self->channels->{'m'}));
    }

    # Yellow channel
    unless (defined($self->channels->{'y'})) {
        $self->update_channels(('y' => 0.0));
    }
    else {
        $self->update_channels(('y' => $self->min_color_val)) if ($self->channels->{'y'} <= $self->min_color_val);
        $self->update_channels(('y' => $self->max_color_val)) if ($self->channels->{'y'} >= $self->max_color_val);
        $self->update_channels(('y' => $self->channels->{'y'}));
    }

    # Key channel
    unless (defined($self->channels->{'k'})) {
        $self->update_channels(('k' => 1.0));
    }
    else {
        $self->update_channels(('k' => $self->min_color_val)) if ($self->channels->{'k'} <= $self->min_color_val);
        $self->update_channels(('k' => $self->max_color_val)) if ($self->channels->{'k'} >= $self->max_color_val);
        $self->update_channels(('k' => $self->channels->{'k'}));
    }
}

# Helper methods
sub _to_rgb {
    my $self = shift;

    # Create a dummy CMYK color object to convert its values to RGB
    my $dummy_cmyk = Convert::Color::CMYK->new($self->channels->{'c'}, $self->channels->{'m'}, $self->channels->{'y'}, $self->channels->{'k'});
    my ($red, $green, $blue) = map {floor($_ * 255)} $dummy_cmyk->rgb();

    return ($red, $green, $blue);
}

# Subclass methods
sub as_cmy {
    my $self = shift;

    # Create a dummy CMYK color object to convert its values to CMY
    my $dummy_cmyk = Convert::Color::CMYK->new($self->channels->{'c'}, $self->channels->{'m'}, $self->channels->{'y'}, $self->channels->{'k'});
    my ($cyan, $magenta, $yellow) = map {$_ * 100} $dummy_cmyk->cmy();

    return sprintf("cmy(%.2f%%, %.2f%%, %.2f%%)", $cyan, $magenta, $yellow);
}

# Overridden parent methods
override as_str => sub {
    my $self = shift;
    my ($cyan, $magenta, $yellow, $key) = map {$_ * 100} ($self->channels->{'c'}, $self->channels->{'m'}, $self->channels->{'y'}, $self->channels->{'k'});  # As percentages

    return sprintf("cmyk(%.2f%%, %.2f%%, %.2f%%, %.2f%%)", $cyan, $magenta, $yellow, $key);
};

override as_hex => sub {
    my $self = shift;
    my ($red, $green, $blue) = $self->_to_rgb();

    return sprintf("#%02x%02x%02x%02x", $red, $green, $blue, 255);  # Since CMY(K) colors are always opaque
};

override as_braille => sub {
    my $self = shift;
    my $class = ref($self); # Parent class (Acuarela::Color)
    my ($red, $green, $blue) = $self->_to_rgb();

    return sprintf(
                "#[%s%s%s%s]",
                chr($class->BRAILLE_PREFIX + $red),
                chr($class->BRAILLE_PREFIX + $green),
                chr($class->BRAILLE_PREFIX + $blue),
                chr($class->BRAILLE_PREFIX + 255)  # Since CMY(K) colors are always opaque
            );
};

__PACKAGE__->meta->make_immutable;
