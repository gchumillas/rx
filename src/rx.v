module rx

import html

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
	effect_stack   []&Effect
	next_effect_id int
}

// Creates and initializes a new reactive context.
// This is the entry point for creating a reactive system.
pub fn context() &Context {
	return &Context{
		next_effect_id: 1
	}
}

/*
Represents a reactive effect and provides mechanisms for creating and managing
effects within the reactive system. Effects are functions that automatically
track their dependencies and re-run when those dependencies change.
*/

// Represents a reactive effect with its dependencies.
struct Effect {
	id  int
	run fn () @[required]
}

// Creates a reactive effect and tracks dependencies.
pub fn (ctx &Context) create_effect(f fn ()) {
	unsafe {
		id := ctx.next_effect_id
		ctx.next_effect_id++

		mut effect := Effect{
			id:  id
			run: f
		}

		ctx.effect_stack << &effect

		// TODO: Clean up old subscriptions (if possible)
		f()

		ctx.effect_stack.delete(ctx.effect_stack.len - 1)
	}
}

// Run a function without tracking dependencies
pub fn (ctx &Context) untrack[T](fn_to_run fn () T) T {
	unsafe {
		old_stack := ctx.effect_stack.clone()
		ctx.effect_stack.clear()
		result := fn_to_run()
		ctx.effect_stack = old_stack.clone()
		return result
	}
}

type ChildrenParam = html.Element | []html.Element
pub fn (ctx &Context) create_element(
	tag_name string,
	children ?ChildrenParam,
	update   ?fn (mut target html.Element)
) html.Element {
	mut target := html.create_element(tag_name: tag_name)
	if children != none {
		match children {
			html.Element {
				println('just one element')
				target.append_child(children)
			}
			[]html.Element {
				for elem in children {
					target.append_child(elem)
				}
			}
		}
	}
	if update != none {
		ctx.create_effect(fn [mut target, update]() {
			update(mut target)
		})
	}
	return target
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
	for _, sub in s.subscribers {
		sub()
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
pub fn ref[T](value T) &Ref[T] {
	return &Ref[T]{
		value: value
	}
}