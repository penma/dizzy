package Dizzy::Textures::Default;

use strict;
use warnings;

use Math::Trig;

sub wrapval {
	   if ($_[0] < 0.0) { return 1.0; }
	elsif ($_[0] > 1.0) { return 0.0; }
	else                { return $_[0]; }
}

my $sf_wrapval = << "// END FUNCTION";
	float wrapval(float val) {
		return (val < 0.0 ? 1.0 : (
		        val > 1.0 ? 0.0 : val)
		);
	}
// END FUNCTION

my @textures = (
	{
		name => "Ornament",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return sin(pi / (0.0001 + 2 * $dist)) / 2 + 0.5;
		},
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = sin(3.141 / (0.001 + 2. * dist)) / 2. + 0.5;
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Spots",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cos($dist * pi) / 2 + 0.5;
		},
	},
	{
		name => "Aurora",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cos($dist * pi + $y / ($dist + 0.0001)) / 2 + 0.5;
		},
	},
	{
		name => "Flowers",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cos($dist * pi + sin(asin($y / ($dist + 0.00001)) * 8) * 0.2) / 2 + 0.5;
		},
	},
	{
		name => "Blurred Circles",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return sin($dist * pi / 2) / 2 + 0.5;
		},
	},
	{
		name => "Blurred Anticircles",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cos($dist * pi + sin(asin($y / ($dist + 0.00001)) * 2) * 0.2) / 2 + 0.5;
		},
	},
	{
		name => "Waves",
		function => sub {
			my ($x, $y) = @_;
			return wrapval((cos($y * pi) + sin($x * pi)) / 2 + 0.5);
		},
		shader => $sf_wrapval . << "		// END SHADER",
			void main() {
				float val = wrapval((cos(gl_TexCoord[0].y * 3.141) + sin(gl_TexCoord[0].x * 3.141)) / 2. + 0.5);
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Crystal",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cos(($x * 2) + asin($y / ($dist + 0.0001))) / 2 + 0.5;
		},
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = cos(
					  2. * (gl_TexCoord[0].x - 0.5)
					+ asin((gl_TexCoord[0].y - 0.5) / dist)
				) / 2. + 0.5;
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Black Circles",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return 1.0 - (cos($dist * pi) / 2 + 0.5);
		},
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = 1 - (cos(dist * 3.141) / 2. + 0.5);
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Hexagon",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return wrapval(asin($y / ($dist + 0.0001)) / 2 + 0.5);
		},
		shader => $sf_wrapval . << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = wrapval(asin((gl_TexCoord[0].y - 0.5) / dist) / 2. + 0.5);
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Boxes",
		function => sub {
			my ($x, $y) = @_;
			return ($x + 0.5) * ($y + 0.5);
		},
		shader => << "		// END SHADER",
			void main() {
				float val = gl_TexCoord[0].x * gl_TexCoord[0].y;
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Bubbles",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cosec($dist + 0.1) / 3;
		},
	},
	{
		name => "Winter Dream",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cosec($dist * 3 + 0.1) / 3;
		},
	},
	{
		name => "Pills",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return -log($dist + 0.01);
		},
	},
	{
		name => "Stars",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return 22.35468769 * $dist**6 + sin(12) * $dist**2 / 5.734;
		},
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = clamp(
					  22.35468769 * pow(dist, 6.0)
					+ sin(12.0) * pow(dist, 2.0) / 5.734
				, 0.0, 1.0);
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
);

sub textures {
	return @textures;
}

1;
