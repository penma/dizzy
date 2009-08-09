#ifndef _DIZZY_ROTATORS_H
#define _DIZZY_ROTATORS_H

#include <GL/gl.h>

typedef void (*dizzyrotators_proc)(int, uint64_t);

struct dizzyrotators {
	dizzyrotators_proc *rotators;
	int rotators_count;
	int current_rotator;
};

int dizzyrotators_init(struct dizzyrotators *dro);
void dizzyrotators_set_rotator(struct dizzyrotators *dro, int rot_id);
void dizzyrotators_apply(struct dizzyrotators *dro, int plane, uint64_t tick);

#endif
