import reactive { create_signal }

fn main() {
	mut count := create_signal(0)

	// Manual simulation of an effect
	count.subscribe(fn () {
		println('Count is now updated')
	})

	println('Initial value: ${count.get()}')
	count.set(1)
	count.set(2)
}
