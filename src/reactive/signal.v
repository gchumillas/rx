module reactive

pub struct Signal[T] {
mut:
	value       T
	subscribers []fn ()
}

pub fn create_signal[T](value T) Signal[T] {
	return Signal[T]{
		value:       value
		subscribers: []
	}
}

pub fn (s Signal[T]) get() T {
	return s.value
}

pub fn (mut s Signal[T]) set(value T) {
	s.value = value
	for sub in s.subscribers {
		sub()
	}
}

pub fn (mut s Signal[T]) subscribe(sub fn ()) {
	s.subscribers << sub
}
