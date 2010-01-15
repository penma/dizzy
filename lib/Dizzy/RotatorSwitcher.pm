package Dizzy::RotatorSwitcher;

use strict;
use warnings;

sub init {
	my ($rotator_switcher, %rotator_switcher_opts) = @_;
	require "Dizzy/RotatorSwitcher/$rotator_switcher.pm";
	my $init = eval '\&Dizzy::RotatorSwitcher::'.$rotator_switcher.'::init';
	die $@ if ($@);
	$init->(%rotator_switcher_opts);
}

1;
