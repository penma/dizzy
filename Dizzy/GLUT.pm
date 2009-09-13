package Dizzy::GLUT;

use strict;
use warnings;

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);

use Dizzy::Handlers;

# default handlers, calling registered handlers and doing other stuff

sub handler_resize {
	glViewport(0, 0, $_[0], $_[1]);
}

sub handler_idle {
	handler_render();

	glFlush();
	glutSwapBuffers();
	sleep(1 / 50);
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
		glutGameModeString(glutGet(GLUT_SCREEN_WIDTH) . "x" . glutGet(GLUT_SCREEN_HEIGHT));
		glutEnterGameMode();
	} else {
		glutInitWindowSize($args{width}, $args{height});
		glutCreateWindow($args{title});
	}

	glutReshapeFunc   (\&handler_resize);
	glutIdleFunc      (\&handler_idle);
	glutDisplayFunc   (\&handler_render);
	glutKeyboardFunc  (\&handler_keyboard);
	glutSpecialFunc   (\&handler_keyboardspecial);
}

sub run {
	glutMainLoop();
}

1;
