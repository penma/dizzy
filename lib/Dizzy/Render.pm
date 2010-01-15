package Dizzy::Render;

use strict;
use warnings;

use OpenGL qw(:all);
use Math::Trig;
use Time::HiRes qw(sleep time);
use Convert::Color;
use Convert::Color::HSV;

use Dizzy::RotatorManager;

my $debug_show_planes;
my $tex_scale;

sub set_color_from_hsv {
	my ($h, $v, $s) = @_;
	glColor3f(Convert::Color::HSV->new($h * 360, $s, $v)->rgb());
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
		if ($debug_show_planes) {
			glScalef(0.2, 0.2, 0.2);
		}

		glMatrixMode(GL_TEXTURE);
		foreach my $tex (GL_TEXTURE1, GL_TEXTURE0) {
			glActiveTextureARB($tex);
			glLoadIdentity();
			glScalef(($tex_scale * 0.3 ** (0.75 + 0.25 * sin(($plane == 1 ? 0.4 : 0.3 ) * $tick))) x 3);
		}
		glMatrixMode(GL_MODELVIEW);

		$args{rotator_func}->($tick, $plane);
		glBegin(GL_QUADS);
		glMultiTexCoord2fARB(GL_TEXTURE0_ARB, 0, 0);
		glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 0, 0);
			glVertex2f(-8, -8);
		glMultiTexCoord2fARB(GL_TEXTURE0_ARB, 0, 1);
		glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 0, 1);
			glVertex2f(-8,  8);
		glMultiTexCoord2fARB(GL_TEXTURE0_ARB, 1, 1);
		glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 1, 1);
			glVertex2f( 8,  8);
		glMultiTexCoord2fARB(GL_TEXTURE0_ARB, 1, 0);
		glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 1, 0);
			glVertex2f( 8, -8);

		glEnd();
		glPopMatrix();
	}
}

sub handler_render {
	render_planes(
		tick => time() - $^T,
		rotator_func => Dizzy::RotatorManager::current(),
	);

	Dizzy::Handlers::GO_ON;
}

sub init {
	my %args = @_;

	# initialize GL view
	glClearColor(0.0, 0.0, 0.0, 0.0);

	glMatrixMode(GL_PROJECTION);
	glOrtho(-3.2, 3.2, 2.0, -2.0, 1, -1);
	glMatrixMode(GL_MODELVIEW);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	# render handler registration
	$debug_show_planes = $args{debug_show_planes};
	$tex_scale = $args{texture_scale};
	Dizzy::Handlers::register(
		render => \&handler_render
	);
	if ($debug_show_planes) {
		Dizzy::Handlers::register_last(render => sub {
			glLineWidth(3);
			glColor4f(1.0, 1.0, 1.0, 1.0);
			my ($xe, $ye) = (3.2 * 0.2, 2.0 * 0.2);
			glBegin(GL_LINE_STRIP);
				glVertex2f( $xe,  $ye);
				glVertex2f(-$xe,  $ye);
				glVertex2f(-$xe, -$ye);
				glVertex2f( $xe, -$ye);
				glVertex2f( $xe,  $ye);
			glEnd();

			Dizzy::Handlers::GO_ON;
		});
	}
}

1;
