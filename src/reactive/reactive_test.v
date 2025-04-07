module reactive
import arrays

fn test_signal_get_set() {
	mut count := Signal.new(0)
	assert count.get() == 0

	count.set(42)
	assert count.get() == 42
}

fn test_effect_reacts_to_changes() {
	mut count := Signal.new(1)
	mut log := &[]int{}

	create_effect(fn [mut log, count] () {
		x := count.get()
		log << x
	})

	count.set(2)
	count.set(3)

	assert log == [1, 2, 3]
}

fn test_effect_runs_once_per_change() {
	mut count := Signal.new(0)
	mut calls := 0

	calls_ref := &calls
	create_effect(fn [calls_ref, count] () {
		_ := count.get()
		unsafe {
			*calls_ref += 1
		}
	})

	count.set(1)
	count.set(2)

	assert calls == 3 // initial run + 2 updates
}

// Test that nested effects run correctly and update independently.
fn test_effect_unsubscribes_on_rerun() {
	mut a := Signal.new(0)
	mut b := Signal.new(0)
	mut chosen := 0
	chosen_ref := &chosen

	create_effect(fn [chosen_ref, a, b] () {
		unsafe {
			if a.get() > 0 {
				*chosen_ref = b.get()
			} else {
				*chosen_ref = a.get()
			}
		}
	})

	a.set(5)
	b.set(42)

	// After switching to tracking b, updates to a should not affect chosen
	a.set(100)
	assert chosen == 42
}

fn test_nested_effects() {
	mut a := Signal.new(1)
	mut b := Signal.new(2)
	mut outer := 0
	mut inner := 0

	outer_ref := &outer
	inner_ref := &inner
	create_effect(fn [a, b, outer_ref, inner_ref] () {
		unsafe {
			*outer_ref = a.get()
		}
		create_effect(fn [b, inner_ref] () {
			unsafe {
				*inner_ref = b.get()
			}
		})
	})

	a.set(10)
	b.set(20)

	assert outer == 10
	assert inner == 20
}
// Check that an effect that depends on multiple signals is re-executed if any of them changes.
fn test_multiple_signals_in_effect() {
	mut a := Signal.new(1)
	mut b := Signal.new(2)
	mut total := 0

	total_ref := &total
	create_effect(fn [a, b, total_ref] () {
		unsafe {
			*total_ref = a.get() + b.get()
		}
	})

	a.set(3)
	b.set(4)

	assert total == 7
}

fn counter_component(start int) Signal[int] {
	count := Signal.new(start)
	create_effect(fn [count] () {
		count.get() // simulate rendering
	})
	return count
}

// Simulates a "component" that uses its own state, without interfering with another.
fn test_component_like_isolation() {
	mut counter1 := counter_component(0)
	mut counter2 := counter_component(100)

	counter1.set(1)
	counter2.set(101)

	assert counter1.get() == 1
	assert counter2.get() == 101
}
