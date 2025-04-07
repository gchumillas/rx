module reactive

// Interface for anything that can be subscribed to.
interface ISubscribable {
	remove_subscriber(effect_id int)
}

// Shared state for a signal
struct SignalState[T] {
mut:
	value       T
	subscribers map[int]fn ()
}

// A reactive signal holding a value and its subscribers.
pub struct Signal[T] {
mut:
	state &SignalState[T]
}

pub fn Signal.new[T](value T) Signal[T] {
	return Signal[T]{
		state: &SignalState[T]{
			value: value
			subscribers: map[int]fn (){}
		}
	}
}

// Returns the current value and registers the active effect (if any).
// This version can be called on an immutable signal.
pub fn (s Signal[T]) get() T {
	if effect_stack.len > 0 {
		mut current := effect_stack[effect_stack.len - 1]
		unsafe {
			s.state.subscribers[current.id] = current.run
			current.subscriptions << s
		}
	}
	return s.state.value
}

// Updates the value and notifies all subscribers.
// This version can be called on an immutable signal.
pub fn (s Signal[T]) set(value T) {
	unsafe {
		s.state.value = value
		for sub in s.state.subscribers.values() {
			sub()
		}
	}
}

// Removes a subscriber by ID.
// This version can be called on an immutable signal.
pub fn (s Signal[T]) remove_subscriber(effect_id int) {
	unsafe {
		s.state.subscribers.delete(effect_id)
	}
}
