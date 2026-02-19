#!/usr/bin/env perl

package Acuarela::Color::BaseColor;

use v5.40;

use strict;
use warnings;
use utf8;
use feature 'declared_refs';
use feature 'signatures';

# Standard imports
use Carp;
use Data::Dumper;

# Class definition
use Moose;
use namespace::autoclean;

# Base color class attributes
has("channels" => (
    'is'        => 'ro',
    'isa'       => 'HashRef[Num]',
    'required'  => 1
));

has("min_color_val" => (
    'is'        => 'ro',
    'writer'    => '_set_lower_bound',
    'isa'       => 'Num',
));

has("max_color_val" => (
    'is'        => 'ro',
    'writer'    => '_set_upper_bound',
    'isa'       => 'Num',
));

# Base color class methods
sub update_channels(@channels) {
    my $self = shift;
    shift(@channels);   # Otherwise it'll contain $self as its first element, which doesn't actually make sense

    foreach my ($channel, $value) (@channels) {   # Because it seems to iterate through the channel array while swapping keys for values for each entry
        #print("\$channel = $channel; \$value = $value\n");
        if (defined($self->channels->{$channel})) {
            if (($value >= $self->min_color_val)
                && ($value <= $self->max_color_val)) {
                $self->channels->{$channel} = $value;
            }
            else {
                croak("Color channel \'${$self->channels->{$channel}}\' is out of bounds (Range = [${$self->min_color_val}, ${$self->max_color_val}])");
            }
        }
        else {
            croak("Color channel \'$channel\' isn't defined in the current color space!");
        }
    }
}

# Should be overridden by all child color classes
sub convert_to($color_space) {;} # Should return the current color's string representation in $color_space

__PACKAGE__->meta->make_immutable;
