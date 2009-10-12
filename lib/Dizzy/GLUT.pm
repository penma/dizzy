package Dizzy::GLUT;

use strict;
use warnings;

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);

use Dizzy::Handlers;
use Dizzy::GLText;

my ($fps_starttime, $fps_frames, $fps_text, $fps_fps) = (time(), 0, "", 0);

sub _fps_reset {
	$fps_starttime = time();
	$fps_frames = 0;
}

sub _fps_update_value {
	$fps_fps = $fps_frames / (time() - $fps_starttime);
}

sub _fps_update_text {
	$fps_text = sprintf("%5.1f FPS (%5.3fs avg)",
		$fps_fps, time() - $fps_starttime);
}

sub _fps_display {
	my $color;
	if ($fps_fps > 25) {
		$color = [0, 1, 0];
	} elsif ($fps_fps > 15) {
		$color = [1 - ($fps_fps - 15) / 10, 1, 0];
	} elsif ($fps_fps > 5) {
		$color = [1, ($fps_fps - 5) / 10, 0];
	} else {
		$color = [1, 0, 0];
	}
	Dizzy::GLText::render_text(10, 10, $color, "test", $fps_text);
}

sub _fps_tick {
	$fps_frames++;
	_fps_display();
	if (time() - $fps_starttime > 0.25) {
		_fps_update_value();
		_fps_update_text();
		_fps_reset();
	}
}

# default handlers, calling registered handlers and doing other stuff

sub handler_idle {
	handler_render();

	glFlush();
	_fps_tick();
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
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA);
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
