module main

import rx
import html

fn create_element(
	ctx &rx.Context,
	tag_name string,
	children []html.Element,
	update   ?fn (mut target html.Element)
) html.Element {
	mut target := html.create_element(tag_name: tag_name)
	for elem in children {
		target.append_child(elem)
	}
	if update != none {
		ctx.create_effect(fn [mut target, update]() {
			update(mut target)
		})
	}
	return target
}

// A simple counter component
fn counter_component() html.Element {
	ctx := rx.context()
	mut count := ctx.signal(0)

	do_increment := fn [mut count]() {
		count.set(count.get() + 1)
	}

	return create_element(
		ctx,
		'div',
		[
			create_element(
				ctx,
				'span',
				[],
				fn [count] (mut target html.Element) {
					target.set_inner_text('${count.get()}')
				}
			)
			create_element(
				ctx,
				'button',
				[],
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
