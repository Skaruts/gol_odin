package main

import "core:mem"
import "core:fmt"


@private tracking_allocator : mem.Tracking_Allocator


@private track_alloc_init :: proc() -> mem.Allocator {
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	return mem.tracking_allocator(&tracking_allocator)
}

@private track_alloc_reset :: proc() -> bool {
	leaks := len(tracking_allocator.allocation_map) > 0
	fmt.printf("\n----------------------------------------------\n")
	if leaks {
		fmt.printf("  Memory leaks: \n")

		for k, v in tracking_allocator.allocation_map {
			fmt.printf("    %v leaked %v bytes\n", v.location, v.size)
		}
	} else {
		fmt.printf("  No memory leaks.\n")
	}
	fmt.printf("----------------------------------------------\n\n")

	mem.tracking_allocator_clear(&tracking_allocator)
	return leaks
}

@private track_alloc_check_bad_frees :: proc() {
	if len(tracking_allocator.bad_free_array) > 0 {
		print("Found bad frees at:")
		for bf in tracking_allocator.bad_free_array {
			fmt.printf("  - %v\n", bf.location)
		}
		panic("There are bad frees!")
	}
}

@private track_alloc_finish :: proc() {
	track_alloc_check_bad_frees()
	track_alloc_reset()
	mem.tracking_allocator_destroy(&tracking_allocator)
}
