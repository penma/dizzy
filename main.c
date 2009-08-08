#include "global.h"

#include "textures.h"
#include "render.h"

int main(int argc, char* argv[])
{
	int w = 1024;
	int h = 768;
	int tres = 64;
	int fullscreen = 0;

	int tb_active = 0;
	int tb_wait = 2000;
	int tb_duration = 5000;

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
			} else if (!strcmp(argv[i], "-tb")) {
				tb_active = 1;
			} else if (!strcmp(argv[i], "-tbwait")) {
				tb_wait = atoi(argv[++i]);
			} else if (!strcmp(argv[i], "-tbduration")) {
				tb_duration = atoi(argv[++i]);
			}
		}
	}

	struct dizzyrender *dr = malloc(sizeof(struct dizzyrender));
	dr->texblend_active = tb_active;
	dr->texblend_wait = tb_wait;
	dr->texblend_duration = tb_duration;
	dizzyrender_init(dr, argc, argv);
	dizzyrender_window(dr, w, h);
	dizzyrender_start(dr, tres);
}

