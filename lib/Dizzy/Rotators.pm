package Dizzy::Rotators;

use strict;
use warnings;

use Dizzy::Rotators::Default;

sub rotators {
	return (
		Dizzy::Rotators::Default::rotators(),
	);
}

1;
