module reactive

fn test_signal_get_set() {
	mut count := Signal.new(0)
	assert count.get() == 0

	count.set(42)
	assert count.get() == 42
}

fn test_effect_reacts_to_changes() {
	mut count := Signal.new(1)
	mut log := Ref.new([]int{})

	create_effect(fn [mut log, count] () {
		log.value << count.get()
	})

	count.set(2)
	count.set(3)

	assert log.value == [1, 2, 3]
}

fn test_effect_runs_once_per_change() {
	mut count := Signal.new(0)
	mut calls := Ref.new(0)

	create_effect(fn [mut calls, count] () {
		_ := count.get()
		calls.value += 1
	})

	count.set(1)
	count.set(2)

	assert calls.value == 3 // initial run + 2 updates
}

// Test that nested effects run correctly and update independently.
fn test_effect_unsubscribes_on_rerun() {
	mut a := Signal.new(0)
	mut b := Signal.new(0)
	mut chosen := Ref.new(0)

	create_effect(fn [mut chosen, a, b] () {
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

fn test_nested_effects() {
	mut a := Signal.new(1)
	mut b := Signal.new(2)
	mut outer := Ref.new(0)
	mut inner := Ref.new(0)

	create_effect(fn [a, b, mut outer, mut inner] () {
		outer.value = a.get()
		create_effect(fn [b, mut inner] () {
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
	mut a := Signal.new(1)
	mut b := Signal.new(2)
	mut total := Ref.new(0)

	create_effect(fn [a, b, mut total] () {
		total.value = a.get() + b.get()
	})

	a.set(3)
	b.set(4)

	assert total.value == 7
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
