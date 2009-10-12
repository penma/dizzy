package Dizzy::Textures::Default;

use strict;
use warnings;

use Math::Trig;

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
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = cos(3.141 * dist) / 2. + 0.5;
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
	},
	{
		name => "Aurora",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = cos((dist * 3.141) + ((gl_TexCoord[0].y - 0.5) / (dist + 0.0001))) / 2. + 0.5;
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
	},
	{
		name => "Flowers",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = cos((dist * 3.141) + (0.2 * sin(8. * asin(
					(gl_TexCoord[0].y - 0.5) / (dist + 0.0001)
					)))) / 2. + 0.5;
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
	},
	{
		name => "Blurred Circles",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = sin(3.141 * dist * 0.5) / 2. + 0.5;
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
	},
	{
		name => "Blurred Anticircles",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = cos((dist * 3.141) + (0.2 * sin(2. * asin(
					(gl_TexCoord[0].y - 0.5) / (dist + 0.0001)
				)))) / 2. + 0.5;
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
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
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = 1. / (sin(dist + 0.1) * 3.);
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
	},
	{
		name => "Winter Dream",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = 1. / (sin(3. * dist + 0.1) * 3.);
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
	},
	{
		name => "Pills",
		shader => << "		// END SHADER",
			void main() {
				float dist = length(gl_TexCoord[0].xy - 0.5);
				float val = -log(dist + 0.01);
				gl_FragColor = vec4(vec3(val), 1.0);
			}
		// END SHADER
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
);

sub textures {
	return @textures;
}

1;
