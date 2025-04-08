module reactive

__global (
	effect_stack   []&Effect
	next_effect_id int
)

// Represents a reactive effect with its dependencies.
struct Effect {
	id  int
	run fn () @[required]
mut:
	subscriptions []ISubscribable
}

// Creates a reactive effect and tracks dependencies.
pub fn create_effect(f fn ()) {
	id := next_effect_id
	next_effect_id++

	mut effect := Effect{
		id:            id
		run:           f
		subscriptions: []
	}

	// Push the effect onto the stack
	effect_stack << &effect

	// Clean up old subscriptions
	for sub in effect.subscriptions {
		sub.remove_subscriber(id)
	}
	effect.subscriptions.clear()

	// Run the effect to register dependencies
	f()

	// Pop the effect from the stack
	effect_stack.delete(effect_stack.len - 1)
}

// Run a function without tracking dependencies
pub fn untrack[T](fn_to_run fn () T) T {
	// Save the current effect stack
	old_stack := effect_stack.clone()
	
	// Clear the effect stack temporarily
	effect_stack.clear()
	
	// Run the function without tracking dependencies
	result := fn_to_run()
	
	// Restore the effect stack
	effect_stack = old_stack.clone()
	
	return result
}

fn init() {
	next_effect_id = 1
}
