module rx

/*
Represents the reactive system's context, which is responsible for managing
reactive effects and their dependencies. The `Context` structure maintains
an internal stack of active effects and assigns unique identifiers to each
effect for tracking purposes.
*/

// Represents the reactive system's context, managing effects and their dependencies.
// The @[heap] attribute ensures the context is allocated on the heap for proper reference handling.
@[heap]
pub struct Context {
mut:
	next_id        int
	current_effect ?&Effect
}

// Creates and initializes a new reactive context.
// This is the entry point for creating a reactive system.
pub fn create_context() &Context {
	return &Context{}
}

/*
Represents a reactive effect and provides mechanisms for creating and managing
effects within the reactive system. Effects are functions that automatically
track their dependencies and re-run when those dependencies change.
*/

// Represents a reactive effect with its dependencies.
struct Effect {
	id       int
	callback fn () @[required]
mut:
	cleaners []fn ()
}

// Creates a reactive effect and tracks dependencies.
pub fn (ctx &Context) create_effect(callback fn ()) {
	unsafe {
		ctx.current_effect = &Effect{
			id: ctx.next_id
			callback: callback
		}
		ctx.next_id++
		callback()
		ctx.current_effect = none
	}
}

pub fn (ctx &Context) on_cleanup(cleaner fn ()) {
	unsafe {
		current_effect := ctx.current_effect
		if current_effect != none {
			current_effect.cleaners << cleaner
		}
	}
}

// Run a function without tracking dependencies
pub fn (ctx &Context) untrack[T](callback fn () T) T {
	unsafe {
		current_effect := ctx.current_effect
		ctx.current_effect = none
		result := callback()
		ctx.current_effect = current_effect
		return result
	}
}

/*
This module defines a reactive programming utility in V, providing a `Signal` structure
that allows for the creation of reactive signals. Signals are reactive values that can
be observed and updated, enabling efficient state management and reactivity in applications.
*/

// Defines a reactive signal that holds a value and manages a list of subscribers.
pub struct Signal[T] {
	ctx &Context
mut:
	value   T
	effects map[int]&Effect
}

// Creates a new signal with the given initial value.
// A signal is a reactive value that can be observed and updated.
pub fn (ctx &Context) create_signal[T](value T) &Signal[T] {
	return &Signal[T]{
		ctx:   ctx
		value: value
	}
}

// Retrieves the current value of the signal and registers any active effect as a subscriber.
// This method can be called on an immutable signal, allowing for broader usage in reactive contexts.
pub fn (s &Signal[T]) get() T {
	unsafe {
		current_effect := s.ctx.current_effect
		if current_effect != none {
			s.effects[current_effect.id] = current_effect
		}
		return s.value
	}
}

// Updates the signal's value and notifies all subscribers about the change.
// This method supports being called on an immutable signal, enhancing flexibility in reactive programming.
pub fn (mut s Signal[T]) set(value T) {
	s.value = value
	for _, effect in s.effects {
		for cleaner in effect.cleaners {
			cleaner()
		}
		effect.callback()
	}
}

/*
The `Ref` struct is a generic wrapper that provides a mutable reference to a value of type `T`.
This is particularly useful in scenarios where direct mutation of a value is not possible,
such as within closures.
*/

pub struct Ref[T] {
pub mut:
	value T
}

// Creates a new reference wrapper for the given value.
// This allows the value to be mutated within closures where direct mutation would not be possible.
pub fn create_ref[T](value T) &Ref[T] {
	return &Ref[T]{
		value: value
	}
}
