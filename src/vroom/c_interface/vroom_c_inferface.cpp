#include <fstream>
#include <iostream>
#include <sstream>
#include <unistd.h>

//including vroom files
#include "problems/vrp.h"
#include "structures/cl_args.h"
#include "structures/typedefs.h"
#include "structures/vroom/input/input.h"
#include "utils/exceptions.h"
#include "utils/input_parser.h"
#include "utils/output_json.h"
#include "utils/version.h"

#define VROOM_ERROR_INPUT_INSTANTIATION 1
#define VROOM_ERROR_ADD_MATRIX 2
#define VROOM_ERROR_ADD_VEHICLE 3
#define VROOM_ERROR_ADD_JOB 4
#define VROOM_ERROR_SOLVE 5


// Functions that are "callable" from julia
extern "C" int vroom_input(bool geometry, void* & input_data) {
	std::unique_ptr<routing_io<cost_t>> routing_wrapper;
	try {
		input_data = new input(std::move(routing_wrapper), geometry);
		return 0;
	} catch (const std::exception& e) {
		std::cout << e.what() << std::endl;
        return VROOM_ERROR_INPUT_INSTANTIATION;
	}
}

extern "C" int vroom_add_matrix(void * data_ptr, int m_size, uint32_t * array) {
	matrix<cost_t> matrix_input(m_size);
	for (int i = 0; i < m_size; ++i) {
		for (int j = 0; j < m_size; ++j) {
			matrix_input[i][j] = array[i*m_size+j];
		}
	}
	try {
		((input *)data_ptr)->set_matrix(std::move(matrix_input));
        return 0;
	} catch (const std::exception& e) {
		std::cout << e.what() << std::endl;
		return VROOM_ERROR_ADD_MATRIX;
	}
}

extern "C" int vroom_add_vehicle(void* data_ptr, uint64_t v_id,
								  int64_t capacity,
								  uint16_t start_index,
								  uint16_t end_index,
								  bool with_tw,
								  uint32_t tw_start,
								  uint32_t tw_end) {
	boost::optional<location_t> start;
	boost::optional<location_t> end;
	start = boost::optional<location_t>(start_index);
	end = boost::optional<location_t>(end_index);
	std::unordered_set<skill_t> skills;
	time_window_t tw;
	if (with_tw) {
		tw = time_window_t(tw_start, tw_end);
	}
	amount_t amount_capacity = amount_t(0);
	amount_capacity.push_back(capacity);
	try {
		vehicle_t v(v_id, start, end, amount_capacity, skills, tw);
		((input*) data_ptr)->add_vehicle((vehicle_t&)v);
        return 0;
	} catch (const std::exception& e) {
		std::cout << e.what() << std::endl;
		return VROOM_ERROR_ADD_VEHICLE;
	}
}

extern "C" int vroom_add_job(void* data_ptr, uint64_t j_id, uint16_t loc_id,
							  uint32_t duration, int64_t capacity_consumption,
							  int nb_tws, uint32_t* tw_starts,
							  uint32_t* tw_ends) {
	const std::unordered_set<skill_t> skills;
	std::vector<time_window_t> tws;
	const location_t job_loc(loc_id);
	if (nb_tws > 0) {
		for (int i = 0; i < nb_tws; ++i) {
			tws.push_back(time_window_t(tw_starts[i], tw_ends[i]));
		}
	} else {
		tws = std::vector<time_window_t>(1, time_window_t());
	}
	amount_t amount(0);
	amount.push_back(capacity_consumption);
	try {
		job_t job(j_id, job_loc, duration, amount, skills, tws);
		((input*) data_ptr)->add_job((job_t&)job);
        return 0;
	} catch (const std::exception& e) {
		std::cout << e.what() << std::endl;
		return VROOM_ERROR_ADD_JOB;
	}
}

extern "C" int vroom_solve(void* data_ptr, int exploration_level,
							int nb_thread, void* &sol) {
	try {
		sol = new solution(((input *)data_ptr)->solve(exploration_level, nb_thread));
		return 0;
	} catch (const std::exception& e) {
		std::cout << e.what() << std::endl;
		return VROOM_ERROR_SOLVE;
	}
}


// Get functions for the solution
extern "C" int vroom_get_sol_cost(void* sol_ptr) {
	return ((solution *)sol_ptr)->summary.cost;
}

extern "C" int vroom_get_service(void* sol_ptr) {
	return ((solution *)sol_ptr)->summary.service;
}

extern "C" int vroom_get_duration(void* sol_ptr) {
	return ((solution *)sol_ptr)->summary.duration;
}

extern "C" int vroom_get_waiting_time(void* sol_ptr) {
	return ((solution *)sol_ptr)->summary.waiting_time;
}

extern "C" int vroom_get_distance(void* sol_ptr) {
	return ((solution *)sol_ptr)->summary.distance;
}

extern "C" int vroom_get_nb_unassigned(void* sol_ptr) {
	return ((solution *)sol_ptr)->summary.unassigned;
}

extern "C" int vroom_get_unassigned_job_id(void* sol_ptr, int index) {
	return ((solution *)sol_ptr)->unassigned[index].id;
}

extern "C" int vroom_get_nb_routes(void* sol_ptr) {
	return ((solution *)sol_ptr)->routes.size();
}

extern "C" int vroom_get_route_nb_actions(void* sol_ptr, int r_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].steps.size();
}

extern "C" int vroom_get_route_vehicle_id(void* sol_ptr, int r_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].vehicle;
}

extern "C" int vroom_get_route_cost(void* sol_ptr, int r_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].cost;
}

extern "C" int vroom_get_route_service(void* sol_ptr, int r_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].service;
}

extern "C" int vroom_get_route_duration(void* sol_ptr, int r_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].duration;
}

extern "C" int vroom_get_route_waiting_time(void* sol_ptr, int r_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].waiting_time;
}

extern "C" int vroom_get_route_distance(void* sol_ptr, int r_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].distance;
}

extern "C" int vroom_get_step_job_id(void* sol_ptr, int r_idx,
									 int step_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].steps[step_idx].job;
}

extern "C" int vroom_get_step_arrival(void* sol_ptr, int r_idx,
									 int step_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].steps[step_idx].arrival;
}

extern "C" int vroom_get_step_waiting_time(void* sol_ptr, int r_idx,
										   int step_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].steps[step_idx].waiting_time;
}

extern "C" int vroom_get_step_distance(void* sol_ptr, int r_idx,
									   int step_idx) {
	return ((solution *)sol_ptr)->routes[r_idx].steps[step_idx].distance;
}
