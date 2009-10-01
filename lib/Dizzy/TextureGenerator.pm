package Dizzy::TextureGenerator;

use strict;
use warnings;

use OpenGL qw(:all);
use Dizzy::GLUT;

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

sub render_function_software {
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

	glTexImage2D_s(
		GL_TEXTURE_2D,
		0,
		GL_LUMINANCE,
		$args{resolution}, $args{resolution},
		0,
		GL_LUMINANCE,
		GL_FLOAT,
		$tex
	);
}

sub render_function_shader {
	my %args = @_;

	# save old viewport
	my (undef, undef, $vx, $vy) = glGetIntegerv_p(GL_VIEWPORT);

	# set a new viewport
	#glViewport(0, 0, $args{resolution}, $args{resolution});

	# prepare projection
	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(-1.0, 1.0, 1.0, -1.0, 1, -1);
	glMatrixMode(GL_MODELVIEW);

	glEnable(GL_TEXTURE_2D);

	# load shader
	my $fragment_id = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
	glShaderSourceARB_p($fragment_id, $args{shader});
	glCompileShaderARB($fragment_id);
	my $stat = glGetInfoLogARB_p($fragment_id);
	print "WARN shader compile $stat\n" if $stat;

	my $shader_prog = glCreateProgramObjectARB();
	glAttachObjectARB($shader_prog, $fragment_id);
	glLinkProgramARB($shader_prog);

	if (!glGetObjectParameterivARB_p($shader_prog, GL_OBJECT_LINK_STATUS_ARB)) {
		my $stat = glGetInfoLogARB_p($shader_prog);
		die("Failed to link shader program: $stat - dying");
	}

	glUseProgramObjectARB($shader_prog);

	# render a plane
	glDrawBuffer(GL_AUX0);
	glReadBuffer(GL_AUX0);

	glClear(GL_COLOR_BUFFER_BIT);

	glLoadIdentity();

	glBegin(GL_QUADS);
		glTexCoord2f(0, 0); glVertex2f(-1, -1);
		glTexCoord2f(0, 1); glVertex2f(-1,  1);
		glTexCoord2f(1, 1); glVertex2f( 1,  1);
		glTexCoord2f(1, 0); glVertex2f( 1, -1);
	glEnd();

	# flush the output, so we can capture it
	glFlush();
	glFinish();

	# read pixels into texture
	glCopyTexImage2D(
		GL_TEXTURE_2D,
		0,
		GL_LUMINANCE,
		0, 0,
		# $args{resolution}, $args{resolution},
		$vx, $vy,
		0
	);

	# reset everything
	glUseProgramObjectARB(0);
	glDeleteObjectARB($shader_prog);
	glDeleteObjectARB($fragment_id);

	glMatrixMode(GL_TEXTURE);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	glViewport(0, 0, $vx, $vy);
	glDrawBuffer(GL_BACK);
	glReadBuffer(GL_BACK);
}

sub render_from_func {
	my %args = @_;

	# confirm resolution. GL likes to choke on non-power-of-two textures
	if (int(log($args{texture_resolution}) / log(2)) != log($args{texture_resolution}) / log(2)) {
		die("Texture size not a power of two, dying");
	}

	# save old texture and prepare new
	my $old_texture = glGetIntegerv_p(GL_TEXTURE_BINDING_2D);
	glBindTexture(GL_TEXTURE_2D, $args{target});

	# render the image
	my $tex_data;
	my $resolution;
	if ($args{shader} and Dizzy::GLUT::supports("glsl")) {
		$resolution = $args{shader_resolution};
		$tex_data = render_function_shader(
			resolution   => $resolution,
			shader       => $args{shader},
		);
	} else {
		$resolution = $args{texture_resolution};
		$tex_data = render_function_software(
			resolution   => $resolution,
			function     => $args{function},
		);
	}

	# restore the old texture
	glBindTexture(GL_TEXTURE_2D, $old_texture);
}

sub new_from_func {
	my %args = @_;

	# allocate a new texture and render into it.
	my $new_texture = create_texture();
	render_from_func(
		function           => $args{function},
		shader             => $args{shader},
		texture_resolution => $args{texture_resolution},
		shader_resolution  => $args{shader_resolution},
		target             => $new_texture,
	);

	return $new_texture;
}

1;
