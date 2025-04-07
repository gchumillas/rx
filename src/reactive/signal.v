module reactive

// Represents a reactive signal
pub struct Signal[T] {
mut:
	value       T
	subscribers []fn ()
}

pub fn Signal.new[T](value T) Signal[T] {
	return Signal[T]{
		value:       value
		subscribers: []
	}
}

// Retrieves the current value of the signal
pub fn (mut s Signal[T]) get() T {
	if effect := current_effect() {
		s.subscribers << effect
	}
	return s.value
}

// Sets a new value for the signal and notifies subscribers
pub fn (mut s Signal[T]) set(value T) {
	s.value = value
	for sub in s.subscribers {
		sub()
	}
}
