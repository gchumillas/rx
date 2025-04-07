module reactive

// Interface defining methods for objects that can be subscribed to.
// This allows for a uniform way of managing subscribers across different types.
interface ISubscribable {
	// Removes a subscriber by their unique identifier.
	// This method is crucial for maintaining a clean list of active subscribers.
	remove_subscriber(effect_id int)
}

// Represents the shared state of a signal, including its current value and list of subscribers.
struct SignalState[T] {
mut:
	// The current value of the signal.
	value       T
	// A map of subscriber identifiers to their corresponding callback functions.
	subscribers map[int]fn ()
}

// Defines a reactive signal that holds a value and manages a list of subscribers.
pub struct Signal[T] {
mut:
	// Reference to the shared state of the signal.
	state &SignalState[T]
}

// Constructor for creating a new Signal with an initial value.
pub fn Signal.new[T](value T) Signal[T] {
	return Signal[T]{
		state: &SignalState[T]{
			value: value
			subscribers: map[int]fn (){}
		}
	}
}

// Retrieves the current value of the signal and registers any active effect as a subscriber.
// This method can be called on an immutable signal, allowing for broader usage in reactive contexts.
pub fn (s Signal[T]) get() T {
	if effect_stack.len > 0 {
		mut current := effect_stack[effect_stack.len - 1]
		unsafe {
			// Registers the current effect as a subscriber to this signal.
			s.state.subscribers[current.id] = current.run
			// Adds this signal to the current effect's list of subscriptions.
			current.subscriptions << s
		}
	}
	return s.state.value
}

// Updates the signal's value and notifies all subscribers about the change.
// This method supports being called on an immutable signal, enhancing flexibility in reactive programming.
pub fn (s Signal[T]) set(value T) {
	unsafe {
		// Updates the value of the signal.
		s.state.value = value
		// Notifies all subscribers by invoking their callback functions.
		for sub in s.state.subscribers.values() {
			sub()
		}
	}
}

// Removes a subscriber from the signal by their identifier.
// This method supports being called on an immutable signal, ensuring that subscriber management can be handled flexibly.
pub fn (s Signal[T]) remove_subscriber(effect_id int) {
	unsafe {
		// Deletes the subscriber from the list based on their identifier.
		s.state.subscribers.delete(effect_id)
	}
}
