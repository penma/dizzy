#ifndef _DIZZY_RENDER_H
#define _DIZZY_RENDER_H

#include <time.h>

struct dizzyrender {
	struct timespec starttime;

	struct dizzytextures *dt;

	int texture_id;
	int texture_id_next;

	int auto_active;
	uint64_t auto_wait;
	uint64_t auto_last;

	int texblend_active;
	uint64_t texblend_start;
	uint64_t texblend_duration;
};

void dizzyrender_init(struct dizzyrender *dr, int argc, char *argv[]);
void dizzyrender_window(struct dizzyrender *dr, int w, int h);
void dizzyrender_start(struct dizzyrender *dr, int texture_res);

#endif
