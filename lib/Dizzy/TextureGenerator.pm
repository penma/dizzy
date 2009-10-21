package Dizzy::TextureGenerator;

use strict;
use warnings;

use File::Path qw(make_path);
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

	# allocate texture memory.
	# on windows systems, passing a NULL pointer to glTexImage2D is faster than
	# allocating and passing the memory manually; in this case, the GL allocates
	# the memory itself.
	# on other systems (tested so far: Linux with MESA), when passing a NULL
	# pointer hell breaks loose and all kinds of render errors are in the texture
	# and so.
	if ($^O eq "MSWin32") {
		glTexImage2D_c(
			GL_TEXTURE_2D, 0,
			GL_RGBA8,
			$args{resolution}, $args{resolution},
			0,
			GL_LUMINANCE, GL_FLOAT,
			0
		);
	} else {
		glTexImage2D_s(
			GL_TEXTURE_2D,
			0,
			GL_RGBA8,
			$args{resolution}, $args{resolution},
			0,
			GL_LUMINANCE, GL_FLOAT,
			pack("f", 0) x ($args{resolution} ** 2)
		);
	}

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

# receives a base path like ./texture_cache/Ornament-256
# will try that file, and possibly compressed formats
sub try_load_cached_texture {
	my ($base_path) = @_;

	# try uncompressed
	if (-e $base_path) {
		open(my $fd, "<", $base_path);
		return join("", <$fd>);
	}

	# try a gzip compressed version
	if (-e "$base_path.gz") {
		open(my $raw_fd, "<", "$base_path.gz");
		require IO::Uncompress::Gunzip;
		my $z = new IO::Uncompress::Gunzip($raw_fd);
		return join("", <$z>);
	}

	# else...
	return undef;
}

sub render_from_func {
	my %args = @_;

	# if GLSL is supported and so, render it freshly, without cache
	# (cache read/write just wastes time here)
	if (Dizzy::GLUT::supports("glsl") and Dizzy::GLUT::supports("fbo")) {
		# if GLSL is supported and stuff, render it
		my $shader = $args{shader} // Dizzy::Perl2GLSL::perl2glsl($args{function});

		render_function_shader(
			resolution   => $args{shader_resolution},
			shader       => $shader,
		);

		return;
	}

	# so it's not supported, try to find it in the cache first.
	if (defined($args{cache_paths})) {
		foreach my $path (@{$args{cache_paths}}) {
			my $name = "$path/$args{name}-$args{texture_resolution}";
			my $data = try_load_cached_texture($name);
			if (defined($data)) {
				glTexImage2D_s(
					GL_TEXTURE_2D,
					0,
					GL_LUMINANCE,
					$args{texture_resolution}, $args{texture_resolution},
					0,
					GL_LUMINANCE,
					GL_FLOAT,
					$data
				);
				return;
			}
		}
	}

	# it's not found in the cache, render it on the CPU.
	render_function_software(
		resolution   => $args{texture_resolution},
		function     => $args{function},
	);

	# if caching is active, write the texture to the cache now.
	if (defined($args{cache_paths}->[0])) {
		eval { make_path($args{cache_paths}->[0]) };
		if ($@) {
			print STDERR "$@ - not writing to cache.\n";
			return;
		}

		my $res = glGetTexLevelParameteriv_p(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH);
		my $fn = "$args{cache_paths}->[0]/$args{name}-$res";
		open(my $outfile, ">", $fn) or do {
			print STDERR "Couldn't write to cache file $fn ($!), not writing to cache.\n";
			return;
		};
		# fucking _s version of this routine is fucking broken, so no way around
		# pointlessly unpacking and repacking the data
		my @pixels = glGetTexImage_p(GL_TEXTURE_2D, 0, GL_LUMINANCE, GL_FLOAT);
		print $outfile pack("f*", @pixels);
		close($outfile);
	}
}

sub new_from_func {
	my %args = @_;

	# allocate a new texture and render into it.
	my $new_texture = create_texture();

	# save old texture and prepare new
	my $old_texture = glGetIntegerv_p(GL_TEXTURE_BINDING_2D);
	glBindTexture(GL_TEXTURE_2D, $new_texture);

	render_from_func(
		name               => $args{name},
		function           => $args{function},
		shader             => $args{shader},
		texture_resolution => $args{texture_resolution},
		shader_resolution  => $args{shader_resolution},
		cache_paths        => $args{cache_paths},
		target             => $new_texture,
	);

	# restore the old texture
	glBindTexture(GL_TEXTURE_2D, $old_texture);

	return $new_texture;
}

1;
