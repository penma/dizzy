package Dizzy::GLUT;

use strict;
use warnings;

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);

# handler registration

my %handlers;

sub call_handlers {
	my ($name, @args) = @_;
	foreach my $handler (@{$handlers{$name}}) {
		$handler->(@args);
	}
}

sub register_handler {
	while (my ($name, $code) = splice(@_, 0, 2)) {
		push(@{$handlers{$name}}, $code);
	}
}

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

	call_handlers("keyboard",
		mouse_x => $x,
		mouse_y => $y,
		ascii   => chr($key),
	);
}

sub handler_keyboardspecial {
	my ($key, $x, $y) = @_;

	call_handlers("keyboard",
		mouse_x => $x,
		mouse_y => $y,
		special => $key,
	);
}

sub handler_render {
	call_handlers("render");
}

# glut initialization

sub init {
	my %args = @_;

	glutInit();
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
	glutInitWindowSize(1024, 768);
	glutCreateWindow($args{title});

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