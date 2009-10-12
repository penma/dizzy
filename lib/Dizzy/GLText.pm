package Dizzy::GLText;

use strict;
use warnings;

use OpenGL qw(:all);

sub mc {
	my ($va, $vb) = @_;
	my $glyph = [[], [], [], [], [], [], [], []];

	for (my $x = 31; $x >= 0; $x--) {
		$glyph->[    int($x / 8)]->[$x % 8] = ($va >> $x) & 1;
		$glyph->[4 + int($x / 8)]->[$x % 8] = ($vb >> $x) & 1;
	}

	return $glyph;
}

my %fonts = (
	test => {
		"" => [ # undefined symbol
			[ .0, .0, .0, .6, .6, .0, .0, .0 ],
			[ .0, .0, .6, .3, .3, .3, .0, .0 ],
			[ .0, .6, 1., 1., 1., .3, .6, .0 ],
			[ .6, 1., 1., 1., .3, .6, 1., .6 ],
			[ .0, 1., 1., .6, .3, 1., 1., .3 ],
			[ .0, .0, 1., 1., .6, 1., .3, .0 ],
			[ .0, .0, .0, .6, .3, .3, .0, .0 ],
			[ .0, .0, .0, .0, .3, .0, .0, .0 ]
		],
		# generated from John Hall's 8x8 bitmapped font <http://overcode.yak.net/12>,
		#   which is "free to use for any purpose".
		# converted it to a luminance-alpha RAW file using GIMP
		# (1024*8*2=16384 bytes)
		# and ran this perl code on it:
		# my $c = 0; while (read(STDIN, $_, 2)) {
		# 	$pixels[int($c / 8)] .= substr($_, 0, 1); $c++; $c %= 128 * 8;
		# } for ($c = 0; $c < 128; $c++) {
		# 	$va = 0; $vb = 0; for ($x = 31; $x >= 0; $x--) {
		# 		$va = (substr($pixels[$c], $x     , 1) eq "\xff" ? 0 : 1) | ($va << 1);
		# 		$vb = (substr($pixels[$c], $x + 32, 1) eq "\xff" ? 0 : 1) | ($vb << 1);
		# 	} printf("\"%c\" => mc(0x%08x, 0x%08x),\n", $c, $va, $vb); }
		" " => mc(0x00000000, 0x00000000), "!" => mc(0x10101010, 0x00100010),
		'"' => mc(0x00002828, 0x00000000), "#" => mc(0x28fe2828, 0x002828fe),
		'$' => mc(0x38147810, 0x00103c50), "%" => mc(0x102c4c00, 0x00006468),
		"&" => mc(0x14081418, 0x005c2262), "'" => mc(0x00001010, 0x00000000),
		"(" => mc(0x08081020, 0x00201008), ")" => mc(0x20201008, 0x00081020),
		"*" => mc(0x38549210, 0x00109254), "+" => mc(0xfe101010, 0x00101010),
		"," => mc(0x00000000, 0x10203030), "-" => mc(0xfe000000, 0x00000000),
		"." => mc(0x00000000, 0x00303000), "/" => mc(0x10204080, 0x00020408),

		"0" => mc(0x54444438, 0x00384444), "1" => mc(0x10101810, 0x00381010),
		"2" => mc(0x20404438, 0x007c0810), "3" => mc(0x30404438, 0x00384440),
		"4" => mc(0x7c242830, 0x00702020), "5" => mc(0x3c04047c, 0x00384440),
		"6" => mc(0x3c044438, 0x00384444), "7" => mc(0x1020407c, 0x00080808),
		"8" => mc(0x38444438, 0x00384444), "9" => mc(0x78444438, 0x00384440),
		":" => mc(0x00303000, 0x00003030), ";" => mc(0x00303000, 0x10203030),
		"<" => mc(0x04081020, 0x00201008), "=" => mc(0x00fe0000, 0x000000fe),
		">" => mc(0x20100804, 0x00040810), "?" => mc(0x20404438, 0x00100010),

		"@" => mc(0x54744438, 0x00380474), "A" => mc(0x7c444438, 0x00444444),
		"B" => mc(0x3c44443c, 0x003c4444), "C" => mc(0x04044438, 0x00384404),
		"D" => mc(0x4444443c, 0x003c4444), "E" => mc(0x3c04047c, 0x007c0404),
		"F" => mc(0x7c04047c, 0x00040404), "G" => mc(0x74044438, 0x00384444),
		"H" => mc(0x7c444444, 0x00444444), "I" => mc(0x10101038, 0x00381010),
		"J" => mc(0x20202070, 0x00182424), "K" => mc(0x1c244444, 0x00444424),
		"L" => mc(0x08080808, 0x00780808), "M" => mc(0x92aac682, 0x00828282),
		"N" => mc(0x54544c44, 0x00444464), "O" => mc(0x44444438, 0x00384444),
		"P" => mc(0x38484838, 0x00080808), "Q" => mc(0x44444438, 0x60384444),
		"R" => mc(0x3c44443c, 0x00442414), "S" => mc(0x38044438, 0x00384440),
		"T" => mc(0x1010107c, 0x00101010), "U" => mc(0x44444444, 0x00384444),
		"V" => mc(0x28444444, 0x00101028), "W" => mc(0x54828282, 0x00282854),
		"X" => mc(0x10284444, 0x00444428), "Y" => mc(0x10284444, 0x00101010),
		"Z" => mc(0x1020407c, 0x007c0408), "[" => mc(0x08080838, 0x00380808),
		"\\"=> mc(0x10080402, 0x00804020), "]" => mc(0x20202038, 0x00382020),
		"^" => mc(0x00442810, 0x00000000), "_" => mc(0x00000000, 0xfe000000),

		"`" => mc(0x00001008, 0x00000000), "a" => mc(0x78403800, 0x00b84444),
		"b" => mc(0x48380808, 0x00344848), "c" => mc(0x04380000, 0x00380404),
		"d" => mc(0x48704040, 0x00b04848), "e" => mc(0x44380000, 0x0038047c),
		"f" => mc(0x1c084830, 0x00080808), "g" => mc(0x44b80000, 0x38407844),
		"h" => mc(0x4c340404, 0x00444444), "i" => mc(0x10001000, 0x00101010),
		"j" => mc(0x10001000, 0x0c101010), "k" => mc(0x14240404, 0x0024140c),
		"l" => mc(0x10101018, 0x00101010), "m" => mc(0x926d0000, 0x00828292),
		"n" => mc(0x48340000, 0x00484848), "o" => mc(0x44380000, 0x00384444),
		"p" => mc(0x48340000, 0x08083848), "q" => mc(0x24580000, 0x20203824),
		"r" => mc(0x0c340000, 0x00040404), "s" => mc(0x04380000, 0x001c2018),
		"t" => mc(0x10381000, 0x00101010), "u" => mc(0x24240000, 0x00582424),
		"v" => mc(0x44440000, 0x00102844), "w" => mc(0x82820000, 0x0044aa92),
		"x" => mc(0x28440000, 0x00442810), "y" => mc(0x48480000, 0x38407048),
		"z" => mc(0x203c0000, 0x003c0810), "{" => mc(0x04080830, 0x00300808),
		"|" => mc(0x10101010, 0x00101010), "}" => mc(0x2010100c, 0x000c1010),
		"~" => mc(0x920c0000, 0x00000060),
	}
);

sub _window_pos {
	my ($x, $y) = @_;

	# get viewport dims
	my (undef, undef, $vx, $vy) = glGetIntegerv_p(GL_VIEWPORT);

	return (
		 (2 * $x / $vx) - 1,
		-(2 * $y / $vy) + 1
	);
}

sub _char {
	my ($glyph, $color) = @_;

	my $pixels = "";
	my $packed_color = pack("f3", @{$color});
	# iterate over the glyph, coloring it in the progress.
	for (my $gy = $#$glyph; $gy >= 0; $gy--) {
		for (my $gx = 0; $gx <= $#{$glyph->[$gy]}; $gx++) {
			$pixels .= $packed_color . pack("f", $glyph->[$gy]->[$gx]);
		}
	}
	glDrawPixels_s(
		scalar(@{$glyph->[0]}),
		scalar(@{$glyph}),
		GL_RGBA, GL_FLOAT,
		$pixels);
}

sub render_text {
	my ($x, $y, $color, $font, $text) = @_;

	# save old state
	my ($old_blend_enable, $old_blend_src, $old_blend_dst);
	$old_blend_enable = glIsEnabled(GL_BLEND);
	$old_blend_src = glGetIntegerv_p(GL_BLEND_SRC);
	$old_blend_dst = glGetIntegerv_p(GL_BLEND_DST);
	my $old_matrix = glGetIntegerv_p(GL_MATRIX_MODE);
	my $old_texture_enable = glIsEnabled(GL_TEXTURE_2D);

	# set blending method we need
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glDisable(GL_TEXTURE_2D);

	# set a new matrix
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();

	# draw the text
	$y += scalar(@{$fonts{$font}->{" "}});
	$x -= scalar(@{$fonts{$font}->{substr($text, 0, 1)}->[0]});
	foreach (split(//, $text)) {
		my $char;
		if ($fonts{$font}->{$_}) {
			$char = $_;
		} else {
			$char = "";
		}

		# draw shadow first
		glRasterPos2f(_window_pos($x + 1, $y + 1));
		_char($fonts{$font}->{$char}, [0, 0, 0]);

		# then draw the main text
		glRasterPos2f(_window_pos($x, $y));
		_char($fonts{$font}->{$char}, $color);

		# and move the "cursor"
		$x += scalar(@{$fonts{$font}->{$char}->[0]});
	}

	# reset state
	if (!$old_blend_enable) {
		glDisable(GL_BLEND);
	}
	glBlendFunc($old_blend_src, $old_blend_dst);

	if ($old_texture_enable) {
		glEnable(GL_TEXTURE_2D);
	}

	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode($old_matrix);
}

1;
