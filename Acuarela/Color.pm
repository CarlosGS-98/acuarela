#!/usr/bin/env perl

package Acuarela::Color;

use v5.40;

use strict;
use warnings;
use utf8;
use utf8::all;
use feature 'declared_refs';
use feature 'signatures';

# Standard imports
use Carp;
use Data::Dumper;

# Class definition
use Moose;
use namespace::autoclean;
no warnings 'experimental::args_array_with_signatures';

# Class constants
use constant BRAILLE_PREFIX => 0x2800;

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
                croak("The new value for color channel \'$channel\' (=$value) is out of bounds (Valid range = [${$self->min_color_val}, ${$self->max_color_val}])");
            }
        }
        else {
            croak("Color channel \'$channel\' isn't defined in the current color space!");
        }
    }
}

# Should be overridden by all child color classes
# sub convert_to($color_space) {
#     # Should return a proper subclass of Acuarela::Color selected by $color_space
#     croak("Abstract color method \'convert_to()\' not implemented");
# }

sub as_str() {
    croak("Abstract color method \'as_str()\' not implemented");
}

sub as_hex() {
    croak("Abstract color method \'as_hex()\' not implemented");
}

sub as_braille() {
    croak("Abstract color method \'as_hex()\' not implemented");
}

__PACKAGE__->meta->make_immutable;
