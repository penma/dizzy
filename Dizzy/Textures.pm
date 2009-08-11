package Dizzy::Textures;

use strict;
use warnings;

use OpenGL qw(:all);

sub create_texture {
	# save old texture
	my $old_texture = glGetIntegerv_p(GL_TEXTURE_BINDING_2D);

	# allocate the new texture
	my $new_texture = (glGenTextures_p(1))[0];
	glBindTexture(GL_TEXTURE_2D, $new_texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

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
			$tex .= pack("C", int($val * 255));
		}
	}

	return ($tex, GL_LUMINANCE);
}

sub from_func {
	my %args = @_;

	# render the image
	my ($tex_data, $tex_format) = render_function(resolution => $args{resolution}, function => $args{function});
	my $tex_pixels = OpenGL::Array->new_scalar(GL_UNSIGNED_BYTE, $tex_data, length($tex_data));

	# save old texture
	my $old_texture = glGetIntegerv_p(GL_TEXTURE_BINDING_2D);

	# allocate new texture
	my $new_texture = create_texture();

	# upload the texture image
	# TODO: why store as GL_RGBA8 internally? / how about textures not stored as unsigned bytes?
	glBindTexture(GL_TEXTURE_2D, $new_texture);
	glTexImage2D_c(
		GL_TEXTURE_2D,
		0,
		GL_RGBA8,
		$args{resolution}, $args{resolution},
		0,
		$tex_format,
		GL_UNSIGNED_BYTE,
		$tex_pixels->ptr()
	);

	# restore the old texture
	glBindTexture(GL_TEXTURE_2D, $old_texture);

	return $new_texture;
}

1;
