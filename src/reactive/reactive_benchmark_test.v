module reactive

import time

// Benchmark for signal creation and updates
fn benchmark_signal_operations() {
	println('Benchmarking signal operations...')
	
	// Measure time to create signals
	start := time.now()
	mut ctx := new_context()
	mut signals := []Signal[int]{cap: 1000}
	for i in 0..1000 {
		signals << ctx.new_signal(i)
	}
	create_time := time.since(start)
	
	// Measure time to get values
	start_get := time.now()
	mut sum := 0
	for i in 0..1000 {
		sum += signals[i].get()
	}
	get_time := time.since(start_get)
	
	// Measure time to set values
	start_set := time.now()
	for i in 0..1000 {
		signals[i].set(i * 2)
	}
	set_time := time.since(start_set)
	
	println('  Created 1000 signals in ${create_time}')
	println('  Get 1000 signal values in ${get_time}')
	println('  Set 1000 signal values in ${set_time}')
}

// Benchmark for effect creation and reactivity
fn benchmark_effect_operations() {
	println('Benchmarking effect operations...')
	
	// Measure time to create effects with a single dependency
	start := time.now()
	mut ctx := new_context()
	mut signals := []Signal[int]{cap: 100}
	mut counters := []int{len: 100, init: 0}
	
	for i in 0..100 {
		signals << ctx.new_signal(i)
		idx := i // Capture for closure
		ctx.create_effect(fn [mut signals, idx, mut counters] () {
			counters[idx] = signals[idx].get()
		})
	}
	create_time := time.since(start)
	
	// Measure time for effect updates
	start_update := time.now()
	for i in 0..100 {
		signals[i].set(i * 3)
	}
	update_time := time.since(start_update)
	
	println('  Created 100 effects in ${create_time}')
	println('  Updated 100 effects in ${update_time}')
	
	// Verify that effects were triggered correctly
	for i in 0..100 {
		assert counters[i] == i * 3
	}
}

// Benchmark for untrack performance
fn benchmark_untrack_performance() {
	println('Benchmarking untrack performance...')
	
	// Setup signals and counters
	mut ctx := new_context()
	mut signal := ctx.new_signal(0)
	mut tracked_counter := 0
	mut untracked_counter := 0
	
	// Create an effect that uses tracked and untracked signal access
	ctx.create_effect(fn [mut ctx, mut signal, mut tracked_counter, mut untracked_counter] () {
		// Tracked access
		start_tracked := time.now()
		tracked_counter = signal.get()
		tracked_time := time.since(start_tracked)
		
		// Untracked access
		start_untracked := time.now()
		untracked_counter = ctx.untrack(fn [mut signal] () int {
			return signal.get()
		})
		untracked_time := time.since(start_untracked)
		
		println('  Tracked access time: ${tracked_time}')
		println('  Untracked access time: ${untracked_time}')
	})
	
	// Trigger the effect multiple times to get average performance
	println('  Running multiple iterations...')
	for i in 1..11 {
		signal.set(i)
	}
}

// Benchmark for comparing tracked vs untracked in large operations
fn benchmark_tracked_vs_untracked_large_operation() {
	println('Benchmarking tracked vs untracked for large operations...')
	
	// Setup
	mut ctx := new_context()
	mut count := ctx.new_signal(0)
	mut tracked_result := 0
	mut untracked_result := 0
	mut tracked_time := time.Duration(0)
	mut untracked_time := time.Duration(0)
	
	// Create an effect that performs a computationally intensive operation
	ctx.create_effect(fn [mut ctx, mut count, mut tracked_result, mut untracked_result, mut tracked_time, mut untracked_time] () {
		// Get the signal value once to register dependency
		base := count.get()
		
		// Tracked expensive operation
		start_tracked := time.now()
		mut sum1 := 0
		for i in 0..10000 {
			// Each get() call would register a dependency
			sum1 += count.get() + i
		}
		tracked_result = sum1
		tracked_time = time.since(start_tracked)
		
		// Untracked expensive operation
		start_untracked := time.now()
		untracked_result = ctx.untrack(fn [mut count] () int {
			mut sum2 := 0
			for i in 0..10000 {
				// No dependencies registered here
				sum2 += count.get() + i
			}
			return sum2
		})
		untracked_time = time.since(start_untracked)
		
		println('  Iteration ${base}:')
		println('    Tracked operation: ${tracked_time}')
		println('    Untracked operation: ${untracked_time}')
		println('    Performance difference: ${f64(tracked_time) / f64(untracked_time)}x')
	})
	
	// Run a few iterations
	for i in 1..6 {
		count.set(i)
	}
}

// Main benchmark function
fn test_benchmarks() {
	println('Running reactive system benchmarks...')
	println('=====================================')
	
	benchmark_signal_operations()
	println('')
	
	benchmark_effect_operations()
	println('')
	
	benchmark_untrack_performance()
	println('')
	
	benchmark_tracked_vs_untracked_large_operation()
	println('')
	
	println('Benchmarks completed.')
}
