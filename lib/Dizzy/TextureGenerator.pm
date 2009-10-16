package Dizzy::TextureGenerator;

use strict;
use warnings;

use OpenGL qw(:all);
use Dizzy::GLUT;
use Dizzy::Perl2GLSL;

use 5.010;

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

	# allocate texture memory
	glTexImage2D_s(
		GL_TEXTURE_2D,
		0,
		GL_RGBA8,
		$args{resolution}, $args{resolution},
		0,
		GL_LUMINANCE, GL_FLOAT,
		pack("f", 0) x ($args{resolution} ** 2)
	);

	# create and use a framebuffer object
	my $fbo = (glGenFramebuffersEXT_p(1))[0];
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, $fbo);
	glFramebufferTexture2DEXT(
		GL_FRAMEBUFFER_EXT,
		GL_COLOR_ATTACHMENT0_EXT,
		GL_TEXTURE_2D,
		glGetIntegerv_p(GL_TEXTURE_BINDING_2D),
		0
	);

	# redefine the viewport (temporarily)
	glPushAttrib(GL_VIEWPORT_BIT);
	glViewport(0, 0, $args{resolution}, $args{resolution});

	# prepare projection
	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(-1.0, 1.0, 1.0, -1.0, 1, -1);
	glMatrixMode(GL_MODELVIEW);

	glEnable(GL_TEXTURE_2D);

	# load shader
	my $fragment_id = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
	glShaderSourceARB_p($fragment_id, $args{shader});
	glCompileShaderARB($fragment_id);
	if (!glGetObjectParameterivARB_p($fragment_id, GL_OBJECT_COMPILE_STATUS_ARB)) {
		my $stat = glGetInfoLogARB_p($fragment_id);
		print STDERR "Shader compilation failed: $stat\n";
		print STDERR "Shader source:\n";
		print STDERR $args{shader} . "\n";
		die();
	}

	my $shader_prog = glCreateProgramObjectARB();
	glAttachObjectARB($shader_prog, $fragment_id);
	glLinkProgramARB($shader_prog);

	if (!glGetObjectParameterivARB_p($shader_prog, GL_OBJECT_LINK_STATUS_ARB)) {
		my $stat = glGetInfoLogARB_p($shader_prog);
		die("Failed to link shader program: $stat - dying");
	}

	glUseProgramObjectARB($shader_prog);

	# render a plane
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

	# reset everything
	glUseProgramObjectARB(0);
	glDeleteObjectARB($shader_prog);
	glDeleteObjectARB($fragment_id);

	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_TEXTURE);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	glDeleteFramebuffersEXT_p($fbo);

	glPopAttrib();
}

sub render_from_func {
	my %args = @_;

	# save old texture and prepare new
	my $old_texture = glGetIntegerv_p(GL_TEXTURE_BINDING_2D);
	glBindTexture(GL_TEXTURE_2D, $args{target});

	# render the image
	if (-e "texture_cache/$args{name}-$args{texture_resolution}") {
		my $name = "texture_cache/$args{name}-$args{texture_resolution}";
		my $res = sqrt((-s $name) / length(pack("f", 0)));
		print "<TextureGenerator> Retrieving texture from cache (${res}x${res})\n"
			if (!$main::seen_texgen_renderer_info);
		$main::seen_texgen_renderer_info = 1;
		open(my $cf, "<", $name);
		glTexImage2D_s(
			GL_TEXTURE_2D,
			0,
			GL_LUMINANCE,
			$res, $res,
			0,
			GL_LUMINANCE,
			GL_FLOAT,
			join("", <$cf>)
		);
		close($cf);
	} elsif (Dizzy::GLUT::supports("glsl") and Dizzy::GLUT::supports("fbo")) {
		print "<TextureGenerator> Using GLSL shaders and FBOs for rendering this texture\n"
			if (!$main::seen_texgen_renderer_info);
		$main::seen_texgen_renderer_info = 1;

		my $shader = $args{shader} // Dizzy::Perl2GLSL::perl2glsl($args{function});

		render_function_shader(
			resolution   => $args{shader_resolution},
			shader       => $shader,
		);
	} else {
		print "<TextureGenerator> using cpu to render this because of missing hardware support.\n"
			if (!$main::seen_texgen_renderer_info);
		$main::seen_texgen_renderer_info = 1;

		render_function_software(
			resolution   => $args{texture_resolution},
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
		name               => $args{name},
		function           => $args{function},
		shader             => $args{shader},
		texture_resolution => $args{texture_resolution},
		shader_resolution  => $args{shader_resolution},
		target             => $new_texture,
	);

	return $new_texture;
}

1;
