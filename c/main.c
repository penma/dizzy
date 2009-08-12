#include "global.h"

#include "textures.h"
#include "render.h"

#define awrite(fd,str) write((fd),(str),strlen((str)))
void usage() {
	awrite(2, "usage: dizzy [options...]\n");

	awrite(2, "   Graphics settings:\n");
	awrite(2, "     -w num           set window width\n");
	awrite(2, "     -h num           set window height\n");
	awrite(2, "     -f               run in fullscreen mode\n");
	awrite(2, "     -t num           set texture resolution (power of two)\n");

	awrite(2, "   Auto mode:\n");
	awrite(2, "     -a               activate auto mode\n");
	awrite(2, "     -aw num          set a new texture every num milliseconds\n");

	awrite(2, "   Texture blending options:\n");
	awrite(2, "     -tb              activate texture blending\n");
	awrite(2, "     -tbduration num  duration of the transition in milliseconds\n");
}

int main(int argc, char* argv[])
{
	int w = 1024;
	int h = 768;
	int tres = 64;

	int auto_active = 0;
	int auto_wait = 7000;
	int tb_active = 0;
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
			} else if (!strcmp(argv[i], "-a")) {
				auto_active = 1;
			} else if (!strcmp(argv[i], "-aw")) {
				auto_wait = atoi(argv[++i]);
			} else if (!strcmp(argv[i], "-tb")) {
				tb_active = 1;
			} else if (!strcmp(argv[i], "-tbduration")) {
				tb_duration = atoi(argv[++i]);
			} else if (!strcmp(argv[i], "--help")) {
				usage();
				exit(0);
			} else {
				awrite(2, "dizzy: unknown argument ");
				awrite(2, argv[i]);
				awrite(2, "\n");
				usage();
				exit(1);
			}
		}
	}

	struct dizzyrender *dr = malloc(sizeof(struct dizzyrender));
	dr->auto_active = auto_active;
	dr->auto_wait = auto_wait;
	dr->texblend_active = tb_active;
	dr->texblend_duration = tb_duration;
	dizzyrender_init(dr, argc, argv);
	dizzyrender_window(dr, w, h);
	dizzyrender_start(dr, tres);
}

