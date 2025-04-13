module rx

// Defines a reactive signal that holds a value and manages a list of subscribers.
pub struct Signal[T] {
	ctx &Context
mut:
	value       T
	subscribers map[int]fn ()
}

// Creates a new signal with the given initial value.
// A signal is a reactive value that can be observed and updated.
pub fn (ctx &Context) signal[T](value T) &Signal[T] {
	return &Signal[T]{
		ctx:         ctx
		value:       value
		subscribers: map[int]fn (){}
	}
}

// Retrieves the current value of the signal and registers any active effect as a subscriber.
// This method can be called on an immutable signal, allowing for broader usage in reactive contexts.
pub fn (s &Signal[T]) get() T {
	if s.ctx.effect_stack.len > 0 {
		mut current := s.ctx.effect_stack[s.ctx.effect_stack.len - 1]
		unsafe {
			s.subscribers[current.id] = current.run
		}
	}
	return s.value
}

// Updates the signal's value and notifies all subscribers about the change.
// This method supports being called on an immutable signal, enhancing flexibility in reactive programming.
pub fn (mut s Signal[T]) set(value T) {
	s.value = value
	for sub in s.subscribers.values() {
		sub()
	}
}
