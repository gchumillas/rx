module main

import rx
import html

fn main() {
	mut ctx := rx.context()
	mut count := ctx.signal(0)
	mut app_elem := html.document.get_element_by_id('app')?

	mut p_elem := html.document.create_element('p')
	ctx.create_effect(fn [mut p_elem, count] () {
		val := count.get()
		p_elem.set_text_content('Count: ${val}')
	})
	app_elem.append_child(p_elem)

	// adds a button
	mut btn_elem := html.document.create_element('button')
	btn_elem.set_text_content('Click me!')
	btn_elem.add_event_listener('click', fn [mut count] () {
		count.set(count.get() + 1)
	})
	app_elem.append_child(btn_elem)
}
