package Dizzy::GLFeatures;

use strict;
use warnings;

use OpenGL qw(glpCheckExtension glGetString GL_VENDOR GL_RENDERER);

# cached capabilities
my %capabilities;

sub update_capabilities {
	$capabilities{glsl} = !glpCheckExtension("GL_ARB_shading_language_100");
	$capabilities{fbo}  = !glpCheckExtension("GL_EXT_framebuffer_object");

	if (is_mesa()) {
		print "warning: MESA library detected, disabling shaders for texture rendering.\n";
		print "         (details: <https://bugs.freedesktop.org/show_bug.cgi?id=24553>)\n";
	}

	# override the detected values, if forced to do so by user
	if (exists($ENV{FORCE_CAP_GLSL})) {
		$capabilities{glsl} = $ENV{FORCE_CAP_GLSL};
		print "note: forcefully overriding GLSL capability\n";
	}

	printf("GPU features: [%s] GLSL     [%s] FBOs\n",
		$capabilities{glsl} ? "x" : " ",
		$capabilities{fbo}  ? "x" : " ",
	);
}

sub supports {
	my $feature = shift;
	return $capabilities{$feature};
}

sub is_mesa {
	# work around mesa bug (<https://bugs.freedesktop.org/show_bug.cgi?id=24553>)
	my $gl_vendor   = glGetString(GL_VENDOR);
	my $gl_renderer = glGetString(GL_RENDERER);
	return "$gl_vendor $gl_renderer" =~ /\bmesa\b/i;
}

1;
