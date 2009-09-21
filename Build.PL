#!/usr/bin/env perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
	dist_name   => 'dizzy',
	dist_author => 'Lars Stoltenow <penma@penma.de>',
	dist_version_from => 'dizzy',
	license     => 'perl',

	requires => {
		"OpenGL"            => '0.58',
		"Convert::Color"    => 0,
		"perl"              => '5.10.0',
	},

	script_files => [ 'dizzy' ],
);
$build->create_build_script;

