#!/usr/bin/env perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
	dist_name   => 'dizzy',
	dist_version => '0.1.0',
	dist_author => 'Lars Stoltenow <penma@penma.de>',
	license     => 'perl',

	requires => {
		"OpenGL"            => '0.58',
		"Convert::Color"    => 0,
		"perl"              => '5.10.0',
	},

	script_files => [ 'dizzy' ],
);
$build->create_build_script;

