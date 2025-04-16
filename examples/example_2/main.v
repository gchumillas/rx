module main

import rx
import html

// A simple counter component
fn counter_component() html.Element {
	ctx := rx.context()
	mut count := ctx.signal(0)

	do_increment := fn [mut count]() {
		count.set(count.get() + 1)
	}

	return ctx.create_element(
		'div',
		[
			ctx.create_element(
				'span',
				none,
				fn [count] (mut target html.Element) {
					target.set_inner_text('${count.get()}')
				}
			)
			ctx.create_element(
				'button',
				none,
				fn [do_increment] (mut target html.Element) {
					target.add_event_listener('click', do_increment)
					target.set_inner_text('Increment')
				}
			)
		],
		none
	)
}

fn main() {
	mut app := html.get_element_by_id('app')?
	app.render(counter_component)
}
