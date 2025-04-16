module main

import rx
import html

fn create_element(
	tag_name string,
	children fn (mut target html.Element) []html.Element
) html.Element {
	mut target := html.create_element(tag_name: tag_name)
	for elem in children(mut target) {
		target.append_child(elem)
	}
	return target
}

// A simple counter component
fn counter_component() html.Element {
	mut ctx := rx.context()
	mut count := ctx.signal(0)

	do_increment := fn [mut count]() {
		count.set(count.get() + 1)
	}

	return create_element(
		'div',
		fn [ctx, count, do_increment] (mut _ html.Element) []html.Element {
			return [
				create_element(
					'span',
					fn [ctx, count] (mut target html.Element) []html.Element {
						ctx.create_effect(fn [mut target, count] () {
							target.set_inner_text('${count.get()}')
						})
						return []
					}
				)
				create_element(
					'button',
					fn [do_increment] (mut target html.Element) []html.Element {
						target.add_event_listener('click', do_increment)
						target.set_inner_text('Increment')
						return []
					}
				)
			]
		}
	)
}

fn main() {
	mut app := html.get_element_by_id('app')?
	app.render(counter_component)
}
