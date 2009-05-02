#include "dizzy_global.h"

#include <GL/glx.h>
#include <GL/gl.h>
#include "dizzy_textures.h"
#include "dizzy_render.h"

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
				w = h = -1;
			} else if (!strcmp(argv[i], "-t")) {
				tres = atoi(argv[++i]);
			}
		}
	}

	struct dizzyrender *dr = malloc(sizeof(struct dizzyrender));
	dizzyrender_init(dr, argc, argv);
	dizzyrender_window(dr, w, h);
	dizzyrender_start(dr, tres);
}

