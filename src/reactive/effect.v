module reactive

// Represents a reactive effect with its dependencies.
struct Effect {
	id  int
	run fn () @[required]
}

// Creates a reactive effect and tracks dependencies.
pub fn (mut ctx Context) create_effect(f fn ()) {
	id := ctx.next_effect_id
	ctx.next_effect_id++

	mut effect := Effect{
		id:            id
		run:           f
	}

	// Push the effect onto the stack
	ctx.effect_stack << &effect

	// TODO: Clean up old subscriptions (if possible)
	// Run the effect to register dependencies
	f()

	// Pop the effect from the stack
	ctx.effect_stack.delete(ctx.effect_stack.len - 1)
}

// Run a function without tracking dependencies
pub fn (mut ctx Context) untrack[T](fn_to_run fn () T) T {
	// Save the current effect stack
	old_stack := ctx.effect_stack.clone()
	
	// Clear the effect stack temporarily
	ctx.effect_stack.clear()
	
	// Run the function without tracking dependencies
	result := fn_to_run()
	
	// Restore the effect stack
	ctx.effect_stack = old_stack.clone()
	
	return result
}

