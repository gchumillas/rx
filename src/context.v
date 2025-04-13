module rx

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
