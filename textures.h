#ifndef _DIZZY_TEXTURES_H
#define _DIZZY_TEXTURES_H

#include <GL/gl.h>

struct dizzytextures {
	int resolution;
	GLuint *textures;
	int textures_count;
	GLuint blend_texture;

	char *current_texture_name;
};

void dizzytextures_init(struct dizzytextures *dt);
void dizzytextures_set_resolution(struct dizzytextures *dt, int res);
void dizzytextures_generate_textures(struct dizzytextures *dt);
void dizzytextures_set_texture(struct dizzytextures *dt, int tex_id);
void dizzytextures_blend_textures(struct dizzytextures *dt, int t1, int t2, double ratio);

#endif
