#include "global.h"
#include "rotators.h"

#include "rotators_data.h"

void dizzyrotators_set_rotator(struct dizzyrotators *dro, int rot_id) {
	dro->current_rotator = rot_id;
	dro->current_rotator_name = dizzyrotators_names[rot_id];
}

void dizzyrotators_apply(struct dizzyrotators *dro, int plane, uint64_t tick) {
	dro->rotators[dro->current_rotator](plane, tick);
}

int dizzyrotators_init(struct dizzyrotators *dro) {
	dro->rotators = malloc(sizeof(dizzyrotators_proc) * dizzyrotators_count);
	dro->rotators_count = dizzyrotators_count;
	for (int rot_id = 0; rot_id < dizzyrotators_count; rot_id++) {
		dro->rotators[rot_id] = dizzyrotators_funcs[rot_id];
	}
	return dro->rotators_count;
}

