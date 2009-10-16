package Dizzy::Textures::Default;

use strict;
use warnings;

use Math::Trig;

sub wrapval {
	my ($val) = @_;
	return ($val < 0.0 ? 1.0 : (
	        $val > 1.0 ? 0.0 : $val)
	);
}

my @textures = (
	{
		name => "Ornament",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return sin(pi / (0.0001 + 2 * $dist)) / 2 + 0.5;
		},
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
	},
	{
		name => "Crystal",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return cos(($x * 2) + asin($y / ($dist + 0.0001))) / 2 + 0.5;
		},
	},
	{
		name => "Black Circles",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return 1.0 - (cos($dist * pi) / 2 + 0.5);
		},
	},
	{
		name => "Hexagon",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return wrapval(asin($y / ($dist + 0.0001)) / 2 + 0.5);
		},
	},
	{
		name => "Boxes",
		function => sub {
			my ($x, $y) = @_;
			return ($x + 0.5) * ($y + 0.5);
		},
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
	},
	{
		name => "Eggs",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return tan($dist);
		},
	},
	{
		name => "Holegrid",
		function => sub {
			my ($x, $y) = @_;
			my $dist = sqrt($x ** 2 + $y ** 2);
			return abs($dist - 0.5) < 0.1;
		},
	},
);

=begin comment

	{
		name => "Swirl",
		shader => << "		// END SHADER",
void main() {
	float vx = gl_TexCoord[0].x - 0.5;
	float vy = gl_TexCoord[0].y - 0.5;

	float vr = length(vec2(vx, vy));
	float vt = atan(vy, vx);

	vt = vt + vr * 16.;
	vx = vr * cos(vt) + 0.5;
	vy = vr * sin(vt) + 0.5;

	float angle = atan(vy, vx);
	float val = (sqrt(abs(sqrt(abs(vy - abs(sin(vx * 5. + 1.4))) * 2.) - 1.))) * (1. - vr * 2.);

	gl_FragColor = vec4(vec3(val), 1.0);
}
		// END SHADER
	},
	{
		name => "Spaceballs",
		shader => << "		// END SHADER",
void main() {
	float vx = gl_TexCoord[0].x - 0.5;
	float vy = gl_TexCoord[0].y - 0.5;

	float vr = length(vec2(vx, vy));
	float vt = atan(vx, 1);

	vt = vt + vr * 16;
	vx = vr * cos(vt) + 0.5;
	vy = vr * sin(vt) + 0.5;

	float angle = atan(vx, 1);
	float val = (sqrt(abs(sqrt(abs(vy - abs(sin(vx * 5 + 1.4))) * 2) - 1)) + (vr + angle / 4)) * (1 - vr * 2);
	gl_FragColor = vec4(vec3(val), 1.0);
}
		// END SHADER
	},

=end comment

=cut

sub textures {
	return @textures;
}

1;
