package Dizzy::TextureManager;

use strict;
use warnings;

use OpenGL qw(:all);
use Math::Trig;
use Time::HiRes qw(sleep time);
use Dizzy::TextureGenerator;
use Dizzy::GLUT;
use Dizzy::Handlers;

my @textures;
my $current_texture_id = 0;
my $previous_texture_id = 0;
my $texture_resolution = 0;

sub add {
	my %args = @_;
	push(@textures, \%args);
	$textures[$#textures]->{gl_texture} = Dizzy::TextureGenerator::new_from_func(
		function     => $textures[$#textures]->{function},
		resolution   => $texture_resolution,
	);
	return $#textures;
}

sub set {
	my ($id) = @_;
	$previous_texture_id = $current_texture_id;
	$current_texture_id = $id;
	Dizzy::Handlers::invoke("texture_switch",
		function           => $textures[$id]->{function},
		previous_function  => $textures[$previous_texture_id]->{function},
	);
}

# -----------------------------------------------------------------------------
# some handlers

# adds a GL texture ID to the request, if we have it
sub handler_add_gl_texture {
	my %args = @_;

	# nothing happens if it already has an ID... or if it doesn't have a function
	if (defined($args{function}) and !defined($args{gl_texture})) {
		foreach my $texture (@textures) {
			if ($texture->{function} == $args{function}) {
				$args{gl_texture} = $texture->{gl_texture};
				Dizzy::Handlers::invoke("texture_switch", %args);
				return Dizzy::Handlers::STOP;
			}
		}
		# not found, pass it on...
		return Dizzy::Handlers::GO_ON;
	} else {
		# no function or already has a handle...
		return Dizzy::Handlers::GO_ON;
	}
}

# transforms a texture walk request (such as one triggered by cursor keys) into
# something that we all understand: a renderable function.
sub handler_walking {
	my %args = @_;

	if (exists($args{direction}) and !exists($args{function})) {
		# find out about the next texture
		my $id = $current_texture_id + $args{direction};
		$id += @textures;
		$id %= @textures;

		set($id);

		return Dizzy::Handlers::STOP;
	} else {
		return Dizzy::Handlers::GO_ON;
	}
}

sub init {
	my %args = @_;

	$texture_resolution = $args{texture_resolution};

	Dizzy::Handlers::register(
		texture_switch => \&handler_add_gl_texture,
		texture_switch => \&handler_walking,
	);
}

1;
