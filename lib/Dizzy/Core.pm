package Dizzy::Core;

use strict;
use warnings;
use 5.010;

use Getopt::Long qw(:config no_ignore_case bundling);

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);

use Dizzy::Handlers;
use Dizzy::GLFeatures;
use Dizzy::GLText;
use Dizzy::Render;

use Dizzy::TextureManager;
use Dizzy::TextureSwitcher;
use Dizzy::Textures;

use Dizzy::RotatorManager;
use Dizzy::RotatorSwitcher;
use Dizzy::Rotators;

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

sub usage_message {
	print STDERR << "EOH";
usage: dizzy [options]

   Graphics settings:
     -w num           set window width
     -h num           set window height
     -f               run in fullscreen mode
     -r num           set texture resolution (power of two)
     -R num           set shader texture resolution
     -z num           set texture zoom
     -c path          set texture cache path
     -C               disable usage of the texture cache

   Auto mode:
     -a num           set a new texture every num seconds

   Texture switching options:
     -t switcher      choose the texture switcher
     -T opt=val       pass options to the texture switcher

   Rotator switching options:
     -d switcher      choose the rotator switcher
     -D opt=val       pass options to the rotator switcher

   Keyboard commands:
   cursor left      select previous texture
   cursor right     select next texture
   cursor down      select previous rotator
   cursor up        select next rotator
   escape           exit dizzy
EOH
}

sub init_arguments {
	# default cache paths
	my $user_cache_root = $ENV{XDG_CACHE_HOME} || "$ENV{HOME}/.cache";
	my @default_cache_paths = (
		"/var/cache/dizzy/textures",
		"$user_cache_root/dizzy/textures"
	);

	my %options = (
		help                   => sub { usage_message(); exit(0); },

		width                  => 0,
		height                 => 0,
		fullscreen             => 0,
		texture_resolution     => 256,
		shader_resolution      => 1024,
		zoom                   => 100,
		cache_paths            => \@default_cache_paths,
		cache_disable          => 0,

		automode               => 0,

		texswitcher            => 'Simple',
		texswitcher_options    => {},

		rotswitcher            => 'Simple',
		rotswitcher_options    => {},
	);

	GetOptions(\%options,
		'help|?',

		'width|w=i',
		'height|h=i',
		'fullscreen|f+',
		'texture_resolution|texture-resolution|r=i',
		'shader_resolution|shader-resolution|R=i',
		'zoom|z=f',
		'cache_paths|cache-paths|c=s',
		'cache_disable|disable-cache|C+',

		'automode|a=f',

		'texswitcher|t=s',
		'texswitcher_options|texswitcher-options|T=s',

		'rotswitcher|d=s',
		'rotswitcher_options|rotswitcher-options|D=s',

		'debug_show_planes|debug-show-planes+',
		'debug_time_startup|debug-time-startup+',
	) or (usage_message(), exit(1));

	return %options;
}

sub init_subsystems {
	my %options = @_;

	Dizzy::Render::init(texture_scale => 4000 / $options{zoom}, debug_show_planes => $options{debug_show_planes});

	# initialize textures
	Dizzy::TextureManager::init(
		texture_resolution => $options{texture_resolution},
		shader_resolution  => $options{shader_resolution},
		cache_paths        => [reverse(@{$options{cache_paths}})],
		cache_disable      => $options{cache_disable},
	);

	my @textures = Dizzy::Textures::textures();
	foreach my $tex (0..$#textures) {
		print STDERR sprintf("Loading textures (%d/%d)\r", $tex + 1, scalar(@textures));
		if ($options{callback_texture_load}) {
			$options{callback_texture_load}->(current => $tex, total => scalar(@textures));
		}
		Dizzy::TextureManager::add(%{$textures[$tex]});
	}

	Dizzy::TextureSwitcher::init(
		$options{texswitcher},
		%{$options{texswitcher_options}},
	);

	# initialize rotator functions
	Dizzy::RotatorManager::init();
	Dizzy::RotatorManager::add(%{$_}) foreach (Dizzy::Rotators::rotators());

	Dizzy::RotatorSwitcher::init(
		$options{rotswitcher},
		%{$options{rotswitcher_options}},
	);

	Dizzy::Handlers::register(
		keyboard => sub {
			my %args = @_;

			# so we don't get warning spam

			if ($args{key} eq "\e" or $args{key} eq "q") { # escape/q
				Dizzy::Handlers::invoke("exit");
			} elsif ($args{key} eq "LEFT" or $args{key} eq "RIGHT") {
				Dizzy::Handlers::invoke("texture_switch",
					direction => (($args{key} eq "LEFT") ? -1 : +1),
				);
			} elsif ($args{key} eq "UP" or $args{key} eq "DOWN") {
				Dizzy::Handlers::invoke("rotator_switch",
					direction => (($args{key} eq "DOWN") ? -1 : +1),
				);
			}

			Dizzy::Handlers::GO_ON;
		},

		# notify user about texture switches
		texture_changed => sub {
			my %args = @_;
			print "*** selected texture \"$args{name}\"\n";
		},

		rotator_changed => sub {
			my %args = @_;
			print "*** selected rotator \"$args{name}\"\n";
		},

		# auto texture changing mode
		render => sub {
			state $last_switch = 0;

			if ($options{automode} > 0) {
				if ($last_switch + $options{automode} <= time()) {
					$last_switch = time();
					Dizzy::Handlers::invoke("texture_switch", direction => +1);
				}
			}

			Dizzy::Handlers::GO_ON;
		},
	);

	Dizzy::TextureManager::set(0);
}

1;
