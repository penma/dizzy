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

void dizzytextures_init(struct dizzytextures *dt) {
	dizzytextures_set_resolution(dt, 64);

	/* no textures have been generated yet */
	dt->textures_count = 0;
	dt->textures = NULL;
}

void dizzytextures_set_resolution(struct dizzytextures *dt, int res) {
	dt->resolution = res;
}

GLuint dizzytextures_generate_texture(struct dizzytextures *dt, double (*texture_func)(double, double)) {
	unsigned char *texture;
	texture = malloc(dt->resolution * dt->resolution * (24 / 8));

	unsigned int texel;
	GLuint texid;

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
	glGenTextures(1, &texid);
	glBindTexture(GL_TEXTURE_2D, texid);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, 3, dt->resolution, dt->resolution, 0, GL_RGB, GL_UNSIGNED_BYTE, texture);

	return texid;
}




void dizzytextures_generate_textures(struct dizzytextures *dt) {
	for (int textype = 0; textype < dizzytextures_data_count; textype++) {
		dt->textures = realloc(dt->textures, sizeof(GLuint) * (dt->textures_count + 1));
		dt->textures[dt->textures_count] = dizzytextures_generate_texture(dt, dizzytextures_data_funcs[textype]);
		dt->textures_count++;
	}
}

