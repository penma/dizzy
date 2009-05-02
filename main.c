#include "dizzy_global.h"

#include <SDL/SDL.h>
#include <GL/glx.h>
#include <GL/gl.h>
#include "dizzy_textures.h"

void setColorFromHSV(float H, float V, float S) {
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

int main(int argc, char* argv[])
{
	int w = 1024;
	int h = 768;
	int tres = 64;
	int fullscreen = 0;

	if(argc > 1)
	{
		for(int i = 1; i < argc; i++)
		{
			if(!strcmp(argv[i], "-w") && (i < argc - 1)) {
				w = atoi(argv[++i]);
			} else if (!strcmp(argv[i], "-h") && (i < argc -1)) {
				h = atoi(argv[++i]);
			} else if (!strcmp(argv[i], "-f")) {
				fullscreen = 1;
			} else if (!strcmp(argv[i], "-t")) {
				tres = atoi(argv[++i]);
			}
		}
	}

	SDL_Init(SDL_INIT_VIDEO);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

	SDL_SetVideoMode(w, h, 24, SDL_OPENGL | SDL_HWSURFACE | SDL_NOFRAME | (fullscreen ? SDL_FULLSCREEN : 0));
	glViewport(0, 0, w, h);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	struct dizzytextures *dt = malloc(sizeof(struct dizzytextures));
	dizzytextures_init(dt);
	dizzytextures_set_resolution(dt, tres);
	dizzytextures_generate_textures(dt);
	dizzytextures_set_texture(dt, 0);

	glMatrixMode(GL_PROJECTION);
	glOrtho(-320, 320, 240, -240, 1, -1);
	glMatrixMode(GL_TEXTURE);
	glScalef(50,50,50);
	glMatrixMode(GL_MODELVIEW);

	int textureID = 0;
	int running = 1;
	int tick;
	SDL_Event event;
	while(running)
	{
		tick = SDL_GetTicks();
		glClear(GL_COLOR_BUFFER_BIT);
		glLoadIdentity();

		setColorFromHSV((tick*0.0002f) - (int)(tick*0.0002f),cos(tick * 0.001f)*0.125f + 0.5f, 0.5f);
		glPushMatrix();
		glRotatef(tick*0.005f, 0, 0, 1);
		glTranslatef(sin(tick * 0.0005f) * 100, cos(tick * 0.00075f) * 100, 0);
		glBegin(GL_QUADS);
			glTexCoord2f( 0, 0); glVertex2f(-800, -800);
			glTexCoord2f( 0, 1); glVertex2f(-800,	800);
			glTexCoord2f( 1, 1); glVertex2f( 800,	800);
			glTexCoord2f( 1, 0); glVertex2f( 800, -800);
		glEnd();
		glPopMatrix();
		glPushMatrix();
		glRotatef(tick*-0.0025f, 0, 0, 1);
		glTranslatef(sin(tick * 0.0005f) * 100, cos(tick * 0.00075f) * 100, 0);
		glBegin(GL_QUADS);
			glTexCoord2f( 0, 0); glVertex2f(-800, -800);
			glTexCoord2f( 0, 1); glVertex2f(-800,	800);
			glTexCoord2f( 1, 1); glVertex2f( 800,	800);
			glTexCoord2f( 1, 0); glVertex2f( 800, -800);
		glEnd();
		glPopMatrix();

		SDL_GL_SwapBuffers();

		while(SDL_PollEvent(&event))
		{
			if(event.type == SDL_QUIT)
				running = 0;
			if(event.type == SDL_KEYUP && event.key.keysym.sym == SDLK_LEFT)
				dizzytextures_set_texture(dt, ++textureID % dt->textures_count);
			if(event.type == SDL_KEYUP && event.key.keysym.sym == SDLK_RIGHT)
				dizzytextures_set_texture(dt, --textureID % dt->textures_count);
			if(event.type == SDL_KEYUP && event.key.keysym.sym == SDLK_ESCAPE)
				running=0;
		}
		SDL_Delay(1);
	}
	SDL_Quit();
}
