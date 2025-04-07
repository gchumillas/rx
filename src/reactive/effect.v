module reactive

// Global variable to keep track of the currently running effect
__global (
	active_effect ?fn ()
)

// Creates an effect that runs the provided function reactively
pub fn create_effect(f fn ()) {
	// Set the active effect to the provided function
	active_effect = f
	// Execute the function once to establish initial dependencies
	f()
	// Reset the active effect
	active_effect = none
}
