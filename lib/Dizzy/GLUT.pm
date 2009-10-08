package Dizzy::GLUT;

use strict;
use warnings;

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);

use Dizzy::Handlers;

# default handlers, calling registered handlers and doing other stuff

sub handler_idle {
	handler_render();

	glFlush();
	glutSwapBuffers();
}

sub handler_keyboard {
	my ($key, $x, $y) = @_;

	Dizzy::Handlers::invoke("keyboard",
		mouse_x => $x,
		mouse_y => $y,
		ascii   => chr($key),
	);
}

sub handler_keyboardspecial {
	my ($key, $x, $y) = @_;

	Dizzy::Handlers::invoke("keyboard",
		mouse_x => $x,
		mouse_y => $y,
		special => $key,
	);
}

sub handler_render {
	Dizzy::Handlers::invoke("render");
}

# glut initialization

sub init {
	my %args = @_;
	$args{width}  ||= 800;
	$args{height} ||= 600;
	$args{fullscreen} ||= 0;

	glutInit();
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
	if ($args{fullscreen}) {
		foreach my $mode (
			glutGet(GLUT_SCREEN_WIDTH) . "x" . glutGet(GLUT_SCREEN_HEIGHT),
			"1024x768",
			"800x600",
			""
		) {
			print "Attempting to initialize game mode $mode\n";
			glutGameModeString($mode);
			if (glutGameModeGet(GLUT_GAME_MODE_POSSIBLE)) {
				glutEnterGameMode();
				last;
			}
		}
		if (glutGameModeGet(GLUT_GAME_MODE_ACTIVE) == 0) {
			die "Fatal error: Couldn't initialize any game mode. ".
				"Try without the -f option.\n";
		}
	} else {
		glutInitWindowSize($args{width}, $args{height});
		glutCreateWindow($args{title});
	}

	glutIdleFunc      (\&handler_idle);
	glutDisplayFunc   (\&handler_render);
	glutKeyboardFunc  (\&handler_keyboard);
	glutSpecialFunc   (\&handler_keyboardspecial);
}

sub run {
	glutMainLoop();
}

# check for capabilities
sub supports {
	my $feature = shift;
	if ($feature eq "glsl") {
		return !glpCheckExtension("GL_ARB_shading_language_100");
	} elsif ($feature eq "fbo") {
		return !glpCheckExtension("GL_EXT_framebuffer_object");
	} else {
		return undef;
	}
}

1;
