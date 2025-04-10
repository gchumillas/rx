module main

import reactive

// Demonstrates the reactive system's capabilities with signals, effects, and untracking.
// This example shows how tracked and untracked dependencies behave differently when signals change.
fn main() {
	mut ctx := reactive.context()
	mut count := ctx.signal(0)
	mut tracked_updates := 0
	mut untracked_updates := 0

	// Effect that tracks the signal
	ctx.create_effect(fn [mut count, mut tracked_updates] () {
		println('Tracked effect: Count is: ${count.get()}')
		tracked_updates++
		println('  Tracked updates: ${tracked_updates}')
	})

	// Effect that uses untrack to prevent dependency tracking
	ctx.create_effect(fn [mut ctx, mut count, mut untracked_updates] () {
		println('Untracked effect: Using untrack to read count')
		ctx.untrack(fn [mut count] () int {
			println('  Untracked count is: ${count.get()}')
			return count.get()
		})
		untracked_updates++
		println('  Untracked updates: ${untracked_updates}')
	})

	println('\nUpdating count to 1...')
	count.set(1) // This will trigger only the tracked effect
	
	println('\nUpdating count to 2...')
	count.set(2) // This will trigger only the tracked effect
	
	println('\nDemonstration of untrack with return value:')
	result := ctx.untrack(fn [mut count] () int {
		value := count.get()
		println('  Reading count (${value}) without tracking')
		return value * 10
	})
	println('  Result of untracked computation: ${result}')
}
