module main

import reactive

fn main() {
	mut count := reactive.Signal.new(0)
	mut tracked_updates := 0
	mut untracked_updates := 0

	// Effect that tracks the signal
	reactive.create_effect(fn [count, mut tracked_updates] () {
		println('Tracked effect: Count is: ${count.get()}')
		tracked_updates++
		println('  Tracked updates: ${tracked_updates}')
	})

	// Effect that uses untrack to prevent dependency tracking
	reactive.create_effect(fn [count, mut untracked_updates] () {
		println('Untracked effect: Using untrack to read count')
		reactive.untrack(fn [count] () int {
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
	result := reactive.untrack(fn [count] () int {
		value := count.get()
		println('  Reading count (${value}) without tracking')
		return value * 10
	})
	println('  Result of untracked computation: ${result}')
}
