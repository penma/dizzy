package Dizzy::TextureGenerator;

use strict;
use warnings;

use OpenGL::Simple qw(:all);

sub create_texture {
	# save old texture
	my $old_texture = glGet(GL_TEXTURE_BINDING_2D);

	# allocate the new texture
	my $new_texture = (glGenTextures(1))[0];
	glBindTexture(GL_TEXTURE_2D, $new_texture);
	glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	# restore the old texture
	glBindTexture(GL_TEXTURE_2D, $old_texture);

	return $new_texture;
}

sub render_function {
	my %args = @_;

	my $tex = "";
	my ($nx, $ny, $val);
	for (my $y = 0; $y < $args{resolution}; $y++) {
		for (my $x = 0; $x < $args{resolution}; $x++) {
			$nx = ($x / $args{resolution}) - 0.5;
			$ny = ($y / $args{resolution}) - 0.5;

			$val = $args{function}->($nx, $ny);

			# clip excessive values
			if ($val > 1.0) {
				$val = 1.0;
			} elsif ($val < 0.0) {
				$val = 0.0;
			}

			# append pixel data
			$tex .= pack("f", $val);
		}
	}

	return $tex;
}

sub render_from_func {
	my %args = @_;

	# confirm resolution. GL likes to choke on non-power-of-two textures
	if (int(log($args{resolution}) / log(2)) != log($args{resolution}) / log(2)) {
		die("Texture size not a power of two, dying");
	}

	# render the image
	my $tex_data = render_function(
		resolution   => $args{resolution},
		function     => $args{function}
	);

	# save old texture
	my $old_texture = glGet(GL_TEXTURE_BINDING_2D);

	# upload the texture image
	glBindTexture(GL_TEXTURE_2D, $args{target});
	glTexImage2D(
		GL_TEXTURE_2D,
		0,
		GL_LUMINANCE,
		$args{resolution}, $args{resolution},
		0,
		GL_LUMINANCE,
		GL_FLOAT,
		\$tex_data,
	);

	# restore the old texture
	glBindTexture(GL_TEXTURE_2D, $old_texture);
}

sub new_from_func {
	my %args = @_;

	# allocate a new texture and render into it.
	my $new_texture = create_texture();
	render_from_func(
		function     => $args{function},
		resolution   => $args{resolution},
		target       => $new_texture,
	);

	return $new_texture;
}

1;
