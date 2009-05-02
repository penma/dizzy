#ifndef _DIZZY_TEXTURES_H
#define _DIZZY_TEXTURES_H

#include <GL/gl.h>

struct dizzytextures {
	int resolution;
	GLuint *textures;
	int textures_count;
};

void dizzytextures_init(struct dizzytextures *dt);
void dizzytextures_set_resolution(struct dizzytextures *dt, int res);
void dizzytextures_generate_textures(struct dizzytextures *dt);

#endif
