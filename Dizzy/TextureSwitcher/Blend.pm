package Dizzy::TextureSwitcher::Blend;

use strict;
use warnings;

use OpenGL qw(:all);
use Math::Trig;
use Time::HiRes qw(time);
use Dizzy::TextureGenerator;
use Dizzy::GLUT;
use Dizzy::Handlers;

my $blend_params = undef;  # parameters of original texture_switch request
my $blend_start;           # time at which current blend was started

my $blend_texture;         # texture ID used for intermediate textures
my $blend_duration = 0;

sub handler_init_switch {
	my %args = @_;
	print "<Texblend> checking if we are blending...\n";
	# check here if we are currently blending. if we are, STOP.
	if (defined($blend_params)) {
		print "<TexBlend> refused texture switch request.\n";
		return Dizzy::Handlers::STOP;
	}

	# else:
	$blend_params = \%args;
	$blend_start = time;
	print "<TexBlend> Starting blend from $blend_params->{old_gl_texture} to $blend_params->{gl_texture}. It's $blend_start now\n";

	Dizzy::Handlers::STOP;
}

# this routine generates and activates intermediate textures
# if there is a blend in progress right now.
# it also sets off necessary events once the blend is finished.
sub handler_render {
	if (defined($blend_params)) {
		# blend the texture. calculate the ratio first
		my $ratio = (time() - $blend_start) / $blend_duration;

		# decide if we are done, or if we need to generate an intermediate image
		# (assert we are done if the source and target match, so we don't block
		# on program start)
		if ($ratio < 1.0 and $blend_params->{old_gl_texture} != $blend_params->{gl_texture}) {
			print "<TexBlend> blending $blend_params->{old_gl_texture} -> $blend_params->{gl_texture}, ratio $ratio\n";

			# retrieve the two textures to be blended
			my (@t1, @t2);
			glBindTexture(GL_TEXTURE_2D, $blend_params->{old_gl_texture});
			@t1 = glGetTexImage_p(GL_TEXTURE_2D, 0, GL_LUMINANCE, GL_FLOAT);
			glBindTexture(GL_TEXTURE_2D, $blend_params->{gl_texture});
			@t2 = glGetTexImage_p(GL_TEXTURE_2D, 0, GL_LUMINANCE, GL_FLOAT);

			# also retrieve their dimensions (just one, actually, and one dimension
			# is sufficient because Dizzy always uses squares)
			my $res = glGetTexLevelParameteriv_p(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH);

			# blend the two
			my $tx;
			while (@t1 > 0) {
				$tx .= pack("f", shift(@t1) * (1 - $ratio) + shift(@t2) * $ratio);
			}

			# now load the blended image into the intermediate texture
			glBindTexture(GL_TEXTURE_2D, $blend_texture);
			glTexImage2D_s(
				GL_TEXTURE_2D,
				0,
				GL_LUMINANCE,
				$res, $res,
				0,
				GL_LUMINANCE,
				GL_FLOAT,
				$tx
			);
		} else {
			print "<TexBlend> finished blending $blend_params->{old_gl_texture} -> $blend_params->{gl_texture}, setting final texture\n";
			glBindTexture(GL_TEXTURE_2D, $blend_params->{gl_texture});
			Dizzy::Handlers::invoke("texture_switched", %{$blend_params});
			$blend_params = undef;
		}
	}

	Dizzy::Handlers::GO_ON;
}

sub init {
	my %args = @_;
	$blend_duration = $args{duration} || 2;

	# allocate a texture for blends
	$blend_texture = Dizzy::TextureGenerator::create_texture();

	Dizzy::Handlers::register(
		texture_switch => \&handler_init_switch,
		render         => \&handler_render,
	);
}

1;
