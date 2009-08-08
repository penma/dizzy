#ifndef _DIZZY_RENDER_H
#define _DIZZY_RENDER_H

#include <time.h>

struct dizzyrender {
	struct timespec starttime;

	struct dizzytextures *dt;

	int texture_id;

	uint64_t texblend_last;
	int64_t texblend_wait;
	int64_t texblend_duration;
};

void dizzyrender_init(struct dizzyrender *dr, int argc, char *argv[]);
void dizzyrender_window(struct dizzyrender *dr, int w, int h);
void dizzyrender_start(struct dizzyrender *dr, int texture_res);

#endif
