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

	foreach my $plane (1, 2) {
		glPushMatrix();
		$args{rotator_func}->($tick, $plane);
		glBegin(GL_QUADS);
			glTexCoord(0, 0); glVertex(-8, -8);
			glTexCoord(0, 1); glVertex(-8,  8);
			glTexCoord(1, 1); glVertex( 8,  8);
			glTexCoord(1, 0); glVertex( 8, -8);
		glEnd();
		glPopMatrix();
	}
}

sub init_view {
	my %args = @_;

	glClearColor(0.0, 0.0, 0.0, 0.0);

	glMatrixMode(GL_PROJECTION);
	glOrtho(-3.2, 3.2, 2.4, -2.4, 1, -1);
	glMatrixMode(GL_TEXTURE);
	glScale(($args{texture_scale}) x 3);
	glMatrixMode(GL_MODELVIEW);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
}

1;
