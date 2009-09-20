package Dizzy::Textures;

use strict;
use warnings;

use Dizzy::Textures::Default;

sub textures {
	return (
		Dizzy::Textures::Default::textures(),
	);
}

1;
