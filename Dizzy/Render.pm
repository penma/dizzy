package Dizzy::Render;

use strict;
use warnings;

use OpenGL::Simple qw(:all);
use OpenGL::Simple::GLUT qw(:all);
use Math::Trig;
use Time::HiRes qw(sleep time);
use Convert::Color;
use Convert::Color::HSV;

sub set_color_from_hsv {
	my ($h, $v, $s) = @_;
	glColor(Convert::Color::HSV->new($h * 360, $s, $v)->rgb());
}

sub render_planes {
	my %args = @_;

	my $tick = $args{tick};

	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();

	set_color_from_hsv(
		($tick * 0.2) - int($tick * 0.2),
		cos($tick) * 0.125 + 0.5,
		0.5);

	glPushMatrix();
	$args{rotator_func}->($tick, 1);
	glBegin(GL_QUADS);
		glTexCoord(0, 0); glVertex(-800, -800);
		glTexCoord(0, 1); glVertex(-800,  800);
		glTexCoord(1, 1); glVertex( 800,  800);
		glTexCoord(1, 0); glVertex( 800, -800);
	glEnd();
	glPopMatrix();

	glPushMatrix();
	$args{rotator_func}->($tick, 2);
	glBegin(GL_QUADS);
		glTexCoord(0, 0); glVertex(-800, -800);
		glTexCoord(0, 1); glVertex(-800,  800);
		glTexCoord(1, 1); glVertex( 800,  800);
		glTexCoord(1, 0); glVertex( 800, -800);
	glEnd();
	glPopMatrix();
}

sub init_view {
	my %args = @_;

	glClearColor(0.0, 0.0, 0.0, 0.0);

	glMatrixMode(GL_PROJECTION);
	glOrtho(-320, 320, 240, -240, 1, -1);
	glMatrixMode(GL_TEXTURE);
	glScale(($args{texture_scale}) x 3);
	glMatrixMode(GL_MODELVIEW);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
}

1;
