#!/usr/bin/env perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->subclass(code => << 'END_SUBCLASS_CODE')->new(
sub process_script_files {
	my $self = shift;
	my $files = $self->find_script_files;
	return unless keys %$files;

	my $script_dir = File::Spec->catdir($self->blib, 'script');
	File::Path::mkpath( $script_dir );

	foreach my $file (keys %$files) {
		my $result = $self->copy_if_modified(
			from => $file,
			to => File::Spec->catfile($script_dir, $files->{$file})
		) or next;
		$self->fix_shebang_line($result) unless $self->is_vmsish;
		$self->make_executable($result);
	}
}

END_SUBCLASS_CODE
	dist_name   => 'dizzy',
	dist_version => '0.01',
	dist_author => 'Lars Stoltenow <penma@penma.de>',
	license     => 'perl',

	requires => {
		"OpenGL"            => '0.58',
		"Convert::Color"    => 0,
		"perl"              => '5.10.0',
	},

	script_files => { 'dizzybin' => 'dizzy' },
);
$build->create_build_script;

