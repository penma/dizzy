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
		# (t2l (cos (* DIST pi)))
	},
	{
		name => "Aurora",
		# (t2l (cos (+ (* DIST pi) (/ Y DIST))))
	},
	{
		name => "Flowers",
		# (t2l (cos (+ (* DIST pi) (* 0.2 (sin (* 8 (asin (/ Y DIST))))))))
	},
	{
		name => "Blurred Circles",
		# (t2l (sin (* DIST pi 0.5)))
	},
	{
		name => "Blurred Anticircles",
		# return cos($dist * pi + sin(asin($y / ($dist + 0.00001)) * 2) * 0.2) / 2 + 0.5;
	},
	{
		name => "Waves",
		shader => $sf_wrapval . << "		// END SHADER",
			void main() {
				float val = wrapval((cos(gl_TexCoord[0].y * 3.141) + sin(gl_TexCoord[0].x * 3.141)) / 2. + 0.5);
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Crystal",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = cos(
					  2. * (gl_TexCoord[0].x - 0.5)
					+ asin((gl_TexCoord[0].y - 0.5) / (dist + 0.01))
				) / 2. + 0.5;
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Black Circles",
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
		shader => $sf_wrapval . << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = wrapval(asin((gl_TexCoord[0].y - 0.5) / (dist + 0.001)) / 2. + 0.5);
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Boxes",
		shader => << "		// END SHADER",
			void main() {
				float val = gl_TexCoord[0].x * gl_TexCoord[0].y;
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
	{
		name => "Bubbles",
		# (/ (cosec (+ DIST 0.1)) 3)
	},
	{
		name => "Winter Dream",
		# (/ (cosec (+ (* DIST 3) 0.1)) 3)
	},
	{
		name => "Pills",
		# (- 0 (ln (+ dist 0.01)))
	},
	{
		name => "Stars",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val =
					  22.35468769 * pow(dist, 6.0)
					+ sin(12.0) * pow(dist, 2.0) / 5.734;
				gl_FragColor = vec4(val, val, val, 1.0);
			}
		// END SHADER
	},
);

sub textures {
	return @textures;
}

1;
