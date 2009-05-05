#include "global.h"

#include <GL/glut.h>
#include <GL/gl.h>

#include "render.h"
#include "textures.h"

static struct dizzyrender *the_dr;

static uint64_t get_tick(struct dizzyrender *dr) {
	struct timespec tp;
	clock_gettime(CLOCK_MONOTONIC, &tp);

	uint64_t diff = (tp.tv_sec - dr->starttime.tv_sec) * 1000
		+ (tp.tv_nsec - dr->starttime.tv_nsec) / 1000000;

	return diff;
}

static void set_color_from_hsv(float H, float V, float S) {
	float var_r, var_g, var_b;
	if (S == 0) {
		glColor3f(V, V, V);
	} else {
		float var_h = H * 6;

		float var_i = (int)(var_h); // Or ... var_i = floor( var_h )
		float var_1 = V * (1 - S);
		float var_2 = V * (1 - (S * (var_h - var_i)));
		float var_3 = V * (1 - (S * (1 - (var_h - var_i))));

		if      (var_i == 0) { var_r = V    ; var_g = var_3; var_b = var_1; }
		else if (var_i == 1) { var_r = var_2; var_g = V    ; var_b = var_1; }
		else if (var_i == 2) { var_r = var_1; var_g = V    ; var_b = var_3; }
		else if (var_i == 3) { var_r = var_1; var_g = var_2; var_b = V    ; }
		else if (var_i == 4) { var_r = var_3; var_g = var_1; var_b = V    ; }
		else                 { var_r = V    ; var_g = var_1; var_b = var_2; }

		glColor3f(var_r, var_g, var_b);
	}
}

void dizzyrender_hand_render() {
	struct dizzyrender *dr = the_dr;

	uint64_t tick = get_tick(dr);
	glClear(GL_COLOR_BUFFER_BIT);
	glLoadIdentity();

	set_color_from_hsv(
		(tick * 0.0002f) - (int)(tick * 0.0002f),
		cos(tick * 0.001f) * 0.125f + 0.5f,
		0.5f);

	glPushMatrix();
	glRotatef(tick * 0.005f, 0, 0, 1);
	glTranslatef(sin(tick * 0.0005f) * 100, cos(tick * 0.00075f) * 100, 0);
	glBegin(GL_QUADS);
		glTexCoord2f(0, 0); glVertex2f(-800, -800);
		glTexCoord2f(0, 1); glVertex2f(-800,  800);
		glTexCoord2f(1, 1); glVertex2f( 800,  800);
		glTexCoord2f(1, 0); glVertex2f( 800, -800);
	glEnd();
	glPopMatrix();

	glPushMatrix();
	glRotatef(tick * -0.0025f, 0, 0, 1);
	glTranslatef(sin(tick * 0.0005f) * 100, cos(tick * 0.00075f) * 100, 0);
	glBegin(GL_QUADS);
		glTexCoord2f(0, 0); glVertex2f(-800, -800);
		glTexCoord2f(0, 1); glVertex2f(-800,  800);
		glTexCoord2f(1, 1); glVertex2f( 800,  800);
		glTexCoord2f(1, 0); glVertex2f( 800, -800);
	glEnd();
	glPopMatrix();
}

void dizzyrender_hand_idle() {
	dizzyrender_hand_render();

	glFlush();
	glutSwapBuffers();
	usleep((int)((1 / 50.0) * 1000000));
}

void dizzyrender_hand_resize(int w, int h) {
	glViewport(0, 0, (GLsizei) w, (GLsizei) h);
}

void dizzyrender_hand_keyboard(unsigned char key, int x, int y) {
	if (key == 27) { /* escape */
		exit(0);
	}
	if (key == 'a') {
		system("xwd -root | convert - png:- | putfile png");
	}
}

void dr_tweak_tex(int val);

void dizzyrender_hand_keyboardspecial(int key, int x, int y) {
	static int tweak_val = 0;
	if (key == GLUT_KEY_LEFT || key == GLUT_KEY_RIGHT) {
		if (key == GLUT_KEY_LEFT) {
			the_dr->texture_id--;
			the_dr->texture_id += the_dr->dt->textures_count;
		} else {
			the_dr->texture_id++;
		}
		the_dr->texture_id %= the_dr->dt->textures_count;
		dizzytextures_set_texture(the_dr->dt, the_dr->texture_id);
	}
	if (key == GLUT_KEY_UP || key == GLUT_KEY_DOWN) {
		if (key == GLUT_KEY_UP) {
			tweak_val++;
		} else {
			tweak_val--;
		}
		printf("tweak_val = %d\n", tweak_val);
		dr_tweak_tex(tweak_val);
	}
}

void dr_tweak_tex(int val) {
	unsigned char *texture;
	texture = malloc(the_dr->dt->resolution * the_dr->dt->resolution * (24 / 8));

	unsigned int texel;
	GLuint texid;

	for (int x = 0; x < the_dr->dt->resolution; x++) {
		for (int y = 0; y < the_dr->dt->resolution; y++) {
			double dx = (the_dr->dt->resolution / 2.0) - x;
			double dy = (the_dr->dt->resolution / 2.0) - y;
			double dist = sqrt(dx*dx + dy*dy) + 0.001;
			double angle = asin(dy / dist);

			double nx = ((double)x / the_dr->dt->resolution) * 2 - 0.5;
			double ny = ((double)y / the_dr->dt->resolution) * 2 - 0.5;
			double nd = (double)dist / the_dr->dt->resolution;

			texel = (unsigned char)(
				// cos(dist / the_dr->dt->resolution * M_PI + sin(angle * val) * val)
				// cos(dist / the_dr->dt->resolution * M_PI + sin(angle * 8) * val)
				// cos(dist * val / the_dr->dt->resolution * M_PI + sin(angle * 8) * 0.02)
				// cos(dist / tan(the_dr->dt->resolution) * M_PI + cos(angle * 8) * 0.02)
				// tan(sin(dist) / the_dr->dt->resolution * M_PI + cos(angle * 8) * 0.02 * val)
				// tan(sin(dist) / the_dr->dt->resolution * M_PI + cos(angle * 8) * 0.02 * val)
				// /// cos(dist / the_dr->dt->resolution * M_PI + sin(angle * 8) * 0.2)
					// cos(dist / the_dr->dt->resolution * M_PI + cos(angle * 8) * 0.2)
					// cos(dist / the_dr->dt->resolution * M_PI + cos(tan(angle) * val) * 0.2)
				0
			* 128 + 128);

			texture[(x * the_dr->dt->resolution + y) * 3    ] = texel;
			texture[(x * the_dr->dt->resolution + y) * 3 + 1] = texel;
			texture[(x * the_dr->dt->resolution + y) * 3 + 2] = texel;
		}
	}

	glGenTextures(1, &texid);
	glBindTexture(GL_TEXTURE_2D, texid);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, 3, the_dr->dt->resolution, the_dr->dt->resolution, 0, GL_RGB, GL_UNSIGNED_BYTE, texture);

	the_dr->dt->textures[0] = texid;

	dizzytextures_set_texture(the_dr->dt, 0);

}

void dizzyrender_prepare_view() {
	glClearColor(0.0, 0.0, 0.0, 0.0);

	glMatrixMode(GL_PROJECTION);
	glOrtho(-320, 320, 240, -240, 1, -1);
	glMatrixMode(GL_TEXTURE);
	glScalef(50, 50, 50);
	glMatrixMode(GL_MODELVIEW);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
}

/* api */

void dizzyrender_init(struct dizzyrender *dr, int argc, char *argv[]) {
	glutInit(&argc, argv);
}

void dizzyrender_window(struct dizzyrender *dr, int w, int h) {
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
	if (w < 0 || h < 0) {
		char gmstring[32];
		snprintf(gmstring, 31, "%dx%d", glutGet(GLUT_SCREEN_WIDTH), glutGet(GLUT_SCREEN_HEIGHT));
		glutGameModeString(gmstring);
		glutEnterGameMode();
	} else {
		glutInitWindowSize(w, h);
		glutCreateWindow("dizzy");
	}

	glutReshapeFunc(dizzyrender_hand_resize);
	glutIdleFunc(dizzyrender_hand_idle);
	glutDisplayFunc(dizzyrender_hand_render);
	glutKeyboardFunc(dizzyrender_hand_keyboard);
	glutSpecialFunc(dizzyrender_hand_keyboardspecial);
}

void dizzyrender_start(struct dizzyrender *dr, int texture_res) {
	/* setup dizzytextures */
	dr->dt = malloc(sizeof(struct dizzytextures));
	dizzytextures_init(dr->dt);
	dizzytextures_set_resolution(dr->dt, texture_res);
	dizzytextures_generate_textures(dr->dt);
	dizzytextures_set_texture(dr->dt, 0);

	/* setup global state */
	clock_gettime(CLOCK_MONOTONIC, &dr->starttime);
	dr->texture_id = 0;

	dizzyrender_prepare_view();

	the_dr = dr;
	glutMainLoop();
}

