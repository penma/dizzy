package Dizzy::TextureSwitcher::Simple;

use strict;
use warnings;

use OpenGL qw(:all);
use Dizzy::Handlers;

sub init {
	Dizzy::Handlers::register(
		texture_switch => sub {
			my %args = @_;
			my $some_texture;
			print "<Simple texture switcher> Changing texture ".
				"($args{old_gl_texture} -> $args{gl_texture})\n";
			glBindTexture(GL_TEXTURE_2D, $args{gl_texture});
			Dizzy::Handlers::invoke("texture_switched", %args);
			Dizzy::Handlers::STOP;
		}
	);
}

1;
