package Dizzy::TextureSwitcher::Blend;

use strict;
use warnings;

use OpenGL qw(:all);
use Math::Trig;
use Time::HiRes qw(time);
use Dizzy::TextureGenerator;
use Dizzy::Handlers;

my $blend_params = undef;  # parameters of original texture_switch request
my $blend_start;           # time at which current blend was started

my $blend_texture;         # texture ID used for intermediate textures
my $blend_duration = 0;

# saved parameters
my $shader_prog;
my $tex_scale;

# blend function to use
my $func_init;
my $func_blend;

sub handler_init_switch {
	my %args = @_;
	print "<Texblend> checking if we are blending...\n";
	# check here if we are currently blending. if we are, STOP.
	if (defined($blend_params)) {
		print "<TexBlend> refused texture switch request.\n";
		return Dizzy::Handlers::STOP;
	}

	# else:
	$blend_params = \%args;
	$blend_start = time;
	print "<TexBlend> Starting blending $blend_params->{old_gl_texture} -> $blend_params->{gl_texture} at $blend_start\n";

	Dizzy::Handlers::STOP;
}

# ******************************* SOFTWARE ***********************************

sub software_init {
	$blend_texture = Dizzy::TextureGenerator::create_texture();
}

# software blend two textures into a third one
sub software_blend {
	my ($tex_a, $tex_b, $ratio) = @_;
	# $tex_a      = first  GL texture ID
	# $tex_b      = second GL texture ID
	# $ratio      = 0.0 .. 1.0 (0.0 = 100% A 0% B, 1.0 = 0% A 100% B)

	# retrieve the two textures to be blended
	my (@data_a, @data_b);
	glBindTexture(GL_TEXTURE_2D, $tex_a);
	@data_a = glGetTexImage_p(GL_TEXTURE_2D, 0, GL_LUMINANCE, GL_FLOAT);
	glBindTexture(GL_TEXTURE_2D, $tex_b);
	@data_b = glGetTexImage_p(GL_TEXTURE_2D, 0, GL_LUMINANCE, GL_FLOAT);

	# also retrieve their dimensions (as the program always uses squares, one
	# dimension suffices)
	my $res = glGetTexLevelParameteriv_p(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH);

	# blend the two textures
	my $target_data;
	while (@data_a > 0) {
		$target_data .= pack("f", shift(@data_a) * (1 - $ratio) + shift(@data_b) * $ratio);
	}

	# now load the blended image into the intermediate texture
	glBindTexture(GL_TEXTURE_2D, $blend_texture);
	glTexImage2D_s(
		GL_TEXTURE_2D,
		0,
		GL_LUMINANCE,
		$res, $res,
		0,
		GL_LUMINANCE,
		GL_FLOAT,
		$target_data
	);
}

# ********************************** GLSL ************************************

sub glsl_init {
	my $fragment_id = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
	glShaderSourceARB_p($fragment_id, << "__END_SHADER__");
uniform sampler2D Texture0;
uniform sampler2D Texture1;
uniform float BlendFactor;

void main() {
	vec4 texel0 = texture2D(Texture0, gl_TexCoord[0].xy);
	vec4 texel1 = texture2D(Texture1, gl_TexCoord[1].xy);
	gl_FragColor.rgb = gl_Color.rgb * mix(texel0, texel1, BlendFactor).r;
	gl_FragColor.a = 1.0;
}
__END_SHADER__
	glCompileShaderARB($fragment_id);
	# my $stat = glGetInfoLogARB_p($fragment_id);
	# print "WARN shader compile $stat\n" if $stat;

	$shader_prog = glCreateProgramObjectARB();
	glAttachObjectARB($shader_prog, $fragment_id);
	glLinkProgramARB($shader_prog);

	if (!glGetObjectParameterivARB_p($shader_prog, GL_OBJECT_LINK_STATUS_ARB)) {
		my $stat = glGetInfoLogARB_p($shader_prog);
		die("Failed to link shader program: $stat - dying");
	}

	glUseProgramObjectARB($shader_prog);
	glUniform1iARB(glGetUniformLocationARB_p($shader_prog, "Texture0"), 0);
	glUniform1iARB(glGetUniformLocationARB_p($shader_prog, "Texture1"), 1);
}

sub glsl_blend {
	my ($tex_a, $tex_b, $ratio) = @_;

	# load the textures
	glActiveTextureARB(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, $tex_a);
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	glScalef(($tex_scale) x 3);
	glMatrixMode(GL_MODELVIEW);

	glActiveTextureARB(GL_TEXTURE1);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, $tex_b);
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	glScalef(($tex_scale) x 3);
	glMatrixMode(GL_MODELVIEW);

	# set the blend factor
	glUniform1fARB(glGetUniformLocationARB_p($shader_prog, "BlendFactor"), $ratio);

	# activate shader
	glUseProgramObjectARB($shader_prog);
}

# ******************************** HANDLERS **********************************

# this routine generates and activates intermediate textures
# if there is a blend in progress right now.
# it also sets off necessary events once the blend is finished.
sub handler_render {
	if (defined($blend_params)) {
		# blend the texture. calculate the ratio first
		my $ratio = (time() - $blend_start) / $blend_duration;

		# decide if we are done, or if we need to generate an intermediate image
		# (assert we are done if the source and target match, so we don't block
		# on program start)
		if ($ratio < 1.0 and $blend_params->{old_gl_texture} != $blend_params->{gl_texture}) {
			print "<TexBlend> Blending $blend_params->{old_gl_texture} -> $blend_params->{gl_texture}, ratio $ratio\n";

			$func_blend->(
				$blend_params->{old_gl_texture},
				$blend_params->{gl_texture},
				$ratio,
			);
		} else {
			print "<TexBlend> Finished blending $blend_params->{old_gl_texture} -> $blend_params->{gl_texture}\n";
			glBindTexture(GL_TEXTURE_2D, $blend_params->{gl_texture});
			Dizzy::Handlers::invoke("texture_switched", %{$blend_params});
			$blend_params = undef;
		}
	}

	Dizzy::Handlers::GO_ON;
}

sub select_render_path {
	# check if glsl is possible
	my $can_glsl = !glpCheckExtension("GL_ARB_shading_language_100");

	# now pick the best
	if ($can_glsl) {
		print "<TexBlend> Using GLSL shaders for blending\n";
		$func_init = \&glsl_init;
		$func_blend = \&glsl_blend;
	} else {
		print "<TexBlend> Falling back to slow software texture blending\n";
		$func_init = \&software_init;
		$func_blend = \&software_blend;
	}
}

sub init {
	my %args = @_;
	$blend_duration = $args{duration} || 2;
	$tex_scale = $args{texture_scale};

	# allocate a texture for blends
	$blend_texture = Dizzy::TextureGenerator::create_texture();

	# select and initialize render path
	select_render_path();
	$func_init->();

	Dizzy::Handlers::register(
		texture_switch => \&handler_init_switch,
		render         => \&handler_render,
	);
}

1;
