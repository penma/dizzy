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

	/* run texture blending */
	if (dr->texblend_active) {
		if (tick - dr->texblend_last > dr->texblend_wait) {
			double blend = (tick - dr->texblend_last - dr->texblend_wait) / (double)dr->texblend_duration;
			if (blend < 1.0) {
				dizzytextures_blend_textures(
					dr->dt,
					dr->texture_id,
					(dr->texture_id + 1) % dr->dt->textures_count,
					blend);
				glBindTexture(GL_TEXTURE_2D, dr->dt->blend_texture);
			} else {
				dr->texblend_last = tick;
				dizzytextures_set_texture(dr->dt, (dr->texture_id + 1) % dr->dt->textures_count);
				dr->texture_id = (dr->texture_id + 1) % dr->dt->textures_count;
			}
		}
	}

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

void dizzyrender_hand_keyboardspecial(int key, int x, int y) {
	struct dizzyrender *dr = the_dr;
	if (key == GLUT_KEY_LEFT || key == GLUT_KEY_RIGHT) {
		/* handle this only if we're not currently blending. */
		if (!dr->texblend_active) {
			if (key == GLUT_KEY_LEFT) {
				dr->texture_id--;
				dr->texture_id += dr->dt->textures_count;
			} else {
				dr->texture_id++;
			}
			dr->texture_id %= dr->dt->textures_count;
			dizzytextures_set_texture(dr->dt, dr->texture_id);
		}
	}
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

