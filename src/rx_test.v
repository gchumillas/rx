module rx

// Tests the basic functionality of signal creation, getting, and setting values.
fn test_signal_get_set() {
	ctx := create_context()
	mut count := ctx.create_signal(0)
	assert count.get() == 0

	count.set(42)
	assert count.get() == 42
}

// Tests that effects properly react to signal changes by executing when dependencies change.
fn test_effect_reacts_to_changes() {
	ctx := create_context()
	mut count := ctx.create_signal(1)
	mut log := create_ref([]int{})

	ctx.create_effect(fn [mut log, count] () {
		log.value << count.get()
	})

	count.set(2)
	count.set(3)

	assert log.value == [1, 2, 3]
}

// Verifies that effects run exactly once per signal change, plus the initial execution.
fn test_effect_runs_once_per_change() {
	ctx := create_context()
	mut count := ctx.create_signal(0)
	mut calls := create_ref(0)

	ctx.create_effect(fn [mut calls, count] () {
		_ := count.get()
		calls.value += 1
	})

	count.set(1)
	count.set(2)

	assert calls.value == 3 // initial run + 2 updates
}

// Test that nested effects run correctly and update independently.
fn test_effect_unsubscribes_on_rerun() {
	ctx := create_context()
	mut a := ctx.create_signal(0)
	mut b := ctx.create_signal(0)
	mut chosen := create_ref(0)

	ctx.create_effect(fn [mut chosen, a, b] () {
		if a.get() > 0 {
			chosen.value = b.get()
		} else {
			chosen.value = a.get()
		}
	})

	a.set(5)
	b.set(42)

	// After switching to tracking b, updates to a should not affect chosen
	a.set(100)
	assert chosen.value == 42
}

// Tests that effects can be nested within other effects and update correctly.
fn test_nested_effects() {
	ctx := create_context()
	mut a := ctx.create_signal(1)
	mut b := ctx.create_signal(2)
	mut outer := create_ref(0)
	mut inner := create_ref(0)

	ctx.create_effect(fn [a, b, ctx, mut outer, mut inner] () {
		outer.value = a.get()
		ctx.create_effect(fn [b, mut inner] () {
			inner.value = b.get()
		})
	})

	a.set(10)
	b.set(20)

	assert outer.value == 10
	assert inner.value == 20
}

// Check that an effect that depends on multiple signals is re-executed if any of them changes.
fn test_multiple_signals_in_effect() {
	ctx := create_context()
	mut a := ctx.create_signal(1)
	mut b := ctx.create_signal(2)
	mut total := create_ref(0)

	ctx.create_effect(fn [a, b, mut total] () {
		total.value = a.get() + b.get()
	})

	a.set(3)
	b.set(4)

	assert total.value == 7
}

// Helper function that simulates a component with its own internal state.
// Creates a signal with the given start value and an effect that tracks it.
fn counter_component(ctx Context, start int) &Signal[int] {
	count := ctx.create_signal(start)
	ctx.create_effect(fn [count] () {
		count.get() // simulate rendering
	})
	return count
}

// Simulates a "component" that uses its own state, without interfering with another.
fn test_component_like_isolation() {
	ctx := create_context()
	mut counter1 := counter_component(ctx, 0)
	mut counter2 := counter_component(ctx, 100)

	counter1.set(1)
	counter2.set(101)

	assert counter1.get() == 1
	assert counter2.get() == 101
}

// Tests that using untrack prevents dependency tracking for signal access within the untracked function.
fn test_untrack_prevents_dependency_tracking() {
	ctx := create_context()
	mut count := ctx.create_signal(1)
	mut triggered := create_ref(false)

	ctx.create_effect(fn [ctx, count, mut triggered] () {
		// Call `get` inside untrack: should NOT register a dependency
		_ := ctx.untrack(fn [count] () int {
			return count.get()
		})
		triggered.value = true
	})

	triggered.value = false
	count.set(2)

	// Since count.get() was untracked, changing count should not rerun the effect
	assert !triggered.value
}

// Tests that signal access outside of untrack still registers dependencies as expected.
fn test_get_outside_untrack_still_tracks() {
	ctx := create_context()
	mut count := ctx.create_signal(1)
	mut triggered := create_ref(false)

	ctx.create_effect(fn [count, mut triggered] () {
		// This should register a dependency
		_ = count.get()
		triggered.value = true
	})

	triggered.value = false
	count.set(2)

	// Since count.get() was not untracked, effect should rerun
	assert triggered.value
}

// Tests that the untrack function correctly returns the value from the untracked function.
fn test_untrack_returns_value() {
	ctx := create_context()
	count := ctx.create_signal(42)
	result := ctx.untrack(fn [count] () int {
		return count.get()
	})
	assert result == 42
}

 
// Tests the cleanup mechanism of the reactive context.
fn test_cleanup() {
	ctx := create_context()
	mut a := ctx.create_signal(0)
	mut b := ctx.create_signal(0)
	mut counter := create_ref(0)

	ctx.create_effect(fn [ctx, a, b, mut counter] () {
		a.get()
		b.get()

		// the callback is executed every time
		// any signal included in this effect changes
		ctx.on_cleanup(fn [mut counter] () {
			counter.value++
		})
	})

	a.set(1)
	b.set(2)
	assert counter.value == 2
}