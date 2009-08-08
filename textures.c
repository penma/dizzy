#include "global.h"
#include "textures.h"

#include "textures_data.h"

void dizzytextures_set_texture(struct dizzytextures *dt, int tex_id) {
	if (dt->textures) {
		if (dt->textures_count) {
			glBindTexture(GL_TEXTURE_2D, dt->textures[tex_id]);
		}
	}
}

GLuint dizzytextures_new_texture(struct dizzytextures *dt);

void dizzytextures_init(struct dizzytextures *dt) {
	dizzytextures_set_resolution(dt, 64);

	/* no textures have been generated yet */
	dt->textures_count = 0;
	dt->textures = NULL;
	dt->blend_texture = dizzytextures_new_texture(dt);
}

void dizzytextures_set_resolution(struct dizzytextures *dt, int res) {
	dt->resolution = res;
}

GLuint dizzytextures_new_texture(struct dizzytextures *dt) {
	GLuint oldtex;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &oldtex);

	GLuint texid;
	glGenTextures(1, &texid);
	glBindTexture(GL_TEXTURE_2D, texid);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glBindTexture(GL_TEXTURE_2D, oldtex);

	return texid;
}

void dizzytextures_render_texture(struct dizzytextures *dt, GLuint texid, double (*texture_func)(double, double)) {
	GLuint oldtex;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &oldtex);

	unsigned char *texture;
	texture = malloc(dt->resolution * dt->resolution * (24 / 8));

	unsigned int texel;

	for (int x = 0; x < dt->resolution; x++) {
		for (int y = 0; y < dt->resolution; y++) {
			double nx = ((double)x / dt->resolution) - 0.5;
			double ny = ((double)y / dt->resolution) - 0.5;

			double txval = texture_func(nx, ny);
			if (txval > 1.0)
				txval = 1.0;
			if (txval < 0.0)
				txval = 0.0;
			texel = (unsigned char)(txval * 255);

			texture[(x * dt->resolution + y) * 3    ] = texel;
			texture[(x * dt->resolution + y) * 3 + 1] = texel;
			texture[(x * dt->resolution + y) * 3 + 2] = texel;
		}
	}

	/* load the texture into opengl */
	glBindTexture(GL_TEXTURE_2D, texid);
	glTexImage2D(GL_TEXTURE_2D, 0, 3, dt->resolution, dt->resolution, 0, GL_RGB, GL_UNSIGNED_BYTE, texture);

	/* restore previous texture */
	glBindTexture(GL_TEXTURE_2D, oldtex);
}

void dizzytextures_generate_textures(struct dizzytextures *dt) {
	for (int textype = 0; textype < dizzytextures_data_count; textype++) {
		dt->textures = realloc(dt->textures, sizeof(GLuint) * (dt->textures_count + 1));
		dt->textures[dt->textures_count] = dizzytextures_new_texture(dt);
		dizzytextures_render_texture(dt, dt->textures[dt->textures_count], dizzytextures_data_funcs[textype]);
		dt->textures_count++;
	}
}

void dizzytextures_blend_textures(struct dizzytextures *dt, int t1, int t2, double ratio) {
	double blend_func(double x, double y) {
		return (
			  (dizzytextures_data_funcs[t1](x, y) * (1.0 - ratio))
			+ (dizzytextures_data_funcs[t2](x, y) * ratio));
	}

	dizzytextures_render_texture(dt, dt->blend_texture, blend_func);
}
