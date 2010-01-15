package Dizzy::RotatorSwitcher::Simple;

use strict;
use warnings;

use OpenGL qw(:all);
use Dizzy::Handlers;

sub init {
	Dizzy::Handlers::register(
		rotator_switch => sub {
			my %args = @_;
			# do stuff
			Dizzy::Handlers::invoke("rotator_switched", %args);
			Dizzy::Handlers::STOP;
		}
	);
}

1;
