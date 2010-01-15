package Dizzy::RotatorManager;

use strict;
use warnings;

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);
use Dizzy::Handlers;

my @rotators;
my $current_rotator_id = 0;

sub add {
	my %args = @_;
	push(@rotators, \%args);
	return $#rotators;
}

sub set {
	my ($id) = @_;
	Dizzy::Handlers::invoke("rotator_switch",
		old_rotator     => $current_rotator_id,
		new_rotator     => $id,
	);
}

sub current {
	return $rotators[$current_rotator_id]->{function};
}

# -----------------------------------------------------------------------------
# some handlers

# transforms a texture walk request (such as one triggered by cursor keys) into
# something that we all understand: a renderable GL texture ID.
sub handler_walking {
	my %args = @_;

	if (exists($args{direction})) {
		# find out about the next texture
		my $id = $current_rotator_id + $args{direction};
		$id += @rotators;
		$id %= @rotators;

		set($id);

		return Dizzy::Handlers::STOP;
	} else {
		return Dizzy::Handlers::GO_ON;
	}
}

# this event serves to tell texman that the texture has now changed.
# it is essentially like texture_switch, but this one is needed for texblend
# to work.
sub handler_switched {
	my %args = @_;

	$current_rotator_id = $args{new_rotator};

	Dizzy::Handlers::invoke("rotator_changed",
		name => $rotators[$current_rotator_id]->{name},
	);

	Dizzy::Handlers::STOP;
}

sub init {
	my %args = @_;

	Dizzy::Handlers::register(
		rotator_switch => \&handler_walking,
	);
	Dizzy::Handlers::register_last(
		rotator_switched => \&handler_switched,
	);
}

1;
