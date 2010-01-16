package Dizzy::Rotators::Default;

use strict;
use warnings;

use OpenGL qw(glRotatef glTranslatef);

my @rotators = (
	{
		name => "Foobar",
		function => sub {
			my ($tick, $plane) = @_;
			if ($plane == 1) {
				glRotatef(sin($tick * 0.75) * 10 + $tick * 5, 0, 0, 1);
				glTranslatef(sin($tick * 0.5), cos($tick * 0.75), 0);
			} elsif ($plane == 2) {
				glRotatef(sin($tick * 0.25) * 50 + $tick * -2.5, 0, 0, 1);
				glTranslatef(sin($tick * 0.5), cos($tick * 0.75), 0);
			}
		},
	},
	{
		name => "Classic",
		function => sub {
			my ($tick, $plane) = @_;
			if ($plane == 1) {
				glRotatef($tick * 5, 0, 0, 1);
				glTranslatef(sin($tick * 0.5), cos($tick * 0.75), 0);
			} else {
				glRotatef($tick * -2.5, 0, 0, 1);
				glTranslatef(sin($tick * 0.5), cos($tick * 0.75), 0);
			}
		},
	},
);

sub rotators {
	return @rotators;
}

1;
