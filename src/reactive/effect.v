module reactive

// Global variable to keep track of the currently running effect
__global (
	effect_stack []fn ()
)

// Pushes a new effect onto the stack and sets it as active
fn push_effect(f fn ()) {
	effect_stack << f
}

// Removes the top effect from the stack
fn pop_effect() {
	if effect_stack.len > 0 {
		effect_stack.delete_last()
	}
}

// Gets the current active effect (top of the stack)
fn current_effect() ?fn () {
	if effect_stack.len > 0 {
		return effect_stack.last()
	}

	return none
}

// Creates an effect that runs the provided function reactively
pub fn create_effect(f fn ()) {
	push_effect(f)
	f()
	pop_effect()
}
