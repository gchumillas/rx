module main

import rx
import html

// A simple counter component
fn counter_component() html.Element {
	ctx := rx.context() // create_context
	mut count := ctx.signal(0) // create_signal

	do_increment := fn [mut count]() {
		count.set(count.get() + 1)
	}

	// <div>
	return ctx.create_element(
		tag_name: 'div'
		children: [
			// <span>{count}</span>
			ctx.create_element(
				tag_name: 'span'
				update: fn [count] (mut target html.Element) {
					target.set_inner_text('${count.get()}')
				}
			)
			// <button onClick={do_increment}>Increment</button>
			ctx.create_element(
				tag_name: 'button'
				children: 'Increment'
				// TODO: this should be init, not update
				update: fn [do_increment] (mut target html.Element) {
					target.add_event_listener('click', do_increment)
				}
			)
		],
	)
}

fn main() {
	mut app := html.get_element_by_id('app')?
	app.render(counter_component)
}
