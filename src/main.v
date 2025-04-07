import reactive { Signal, create_effect }

fn main() {
	mut count := Signal.new(0)

	create_effect(fn [count] () {
		println('Effect 1: Count is: ${count.get()}')
	})

	create_effect(fn [count] () {
		println('Effect 2: Count is: ${count.get()}')
	})

	count.set(1) // This will trigger the effects and show "Count is: 1"
	count.set(2) // This will trigger the effects and show "Count is: 2"
}
