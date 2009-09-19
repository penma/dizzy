package Dizzy::TextureSwitcher;

use strict;
use warnings;

sub init {
	my ($tex_switcher, %tex_switcher_opts) = @_;
	require "Dizzy/TextureSwitcher/$tex_switcher.pm";
	my $init = eval '\&Dizzy::TextureSwitcher::'.$tex_switcher.'::init';
	die $@ if ($@);
	$init->(%tex_switcher_opts);
}

1;
