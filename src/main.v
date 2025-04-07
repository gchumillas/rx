import reactive { Signal, create_effect }

fn main() {
	mut count := Signal.new(0)

	create_effect(fn [mut count] () {
		println('Count is: ${count.get()}')
	})

	count.set(1) // Esto desencadenará el efecto y mostrará "Count is: 1"
	count.set(2) // Esto desencadenará el efecto y mostrará "Count is: 2"
}
