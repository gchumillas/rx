# SolidV

A port of [SolidJS](https://www.solidjs.com/) reactivity system to the V programming language.

## Overview

SolidV aims to bring the fine-grained reactivity system of SolidJS to V. The core principle is to track dependencies automatically and update only what has changed, providing efficient and predictable reactivity.

## Features

- **Fine-grained reactivity**: Only the specific parts of your application that depend on changed state are updated
- **Automatic dependency tracking**: Dependencies are tracked automatically during execution
- **Signals**: Reactive state containers that notify subscribers when their value changes
- **Effects**: Side effects that automatically re-execute when their dependencies change
- **Untracking**: Ability to access reactive state without creating dependencies

## Current Implementation

The current implementation includes the core reactivity primitives:

- `Signal<T>`: A reactive value container
- `create_effect`: Creates a side effect that automatically re-executes when its dependencies change
- `untrack`: Accesses reactive state without creating dependencies
- `Ref<T>`: A simple container for non-primitive values

## API Documentation

### Signal

```v
// Create a new signal with an initial value
signal := Signal.new(initial_value)

// Get the current value (automatically tracks dependencies)
value := signal.get()

// Set a new value (automatically notifies subscribers)
signal.set(new_value)
```

### Effects

```v
// Create an effect that automatically re-executes when its dependencies change
create_effect(fn [dependencies] () {
    // This code will re-run whenever any accessed signal changes
    value := some_signal.get()
    // Do something with the value
})
```

### Untrack

```v
// Access reactive state without creating dependencies
untrack(fn [signal] () {
    // This won't create a dependency on the signal
    value := signal.get()
})

// Untrack can also return values
result := untrack(fn [signal] () int {
    return signal.get()
})
```

## Examples

### Simple Counter

```v
module main

import reactive

fn main() {
    // Create a signal with initial value 0
    mut count := reactive.Signal.new(0)
    
    // Create an effect that prints the count whenever it changes
    reactive.create_effect(fn [count] () {
        println('Count: ${count.get()}')
    })
    
    // Update the count, which will trigger the effect
    count.set(1)
    count.set(2)
}
```

### Computed Values

```v
module main

import reactive

fn main() {
    // Create signals
    mut first_name := reactive.Signal.new('John')
    mut last_name := reactive.Signal.new('Doe')
    
    // Create an effect that computes a derived value
    reactive.create_effect(fn [first_name, last_name] () {
        full_name := '${first_name.get()} ${last_name.get()}'
        println('Full name: ${full_name}')
    })
    
    // Update the signals, which will trigger the effect
    first_name.set('Jane')
}
```

### Using Untrack

```v
module main

import reactive

fn main() {
    mut count := reactive.Signal.new(0)
    mut should_update := reactive.Signal.new(true)
    
    reactive.create_effect(fn [count, should_update] () {
        // This will only create a dependency on should_update, not on count
        if should_update.get() {
            reactive.untrack(fn [count] () {
                println('Count: ${count.get()}')
            })
        }
    })
    
    // This won't trigger the effect because count is accessed inside untrack
    count.set(1)
    
    // This will trigger the effect
    should_update.set(false)
    should_update.set(true)
}
```

## Performance

SolidV is designed to be highly performant. Benchmarks show:

- Signal operations are very fast (microseconds)
- Effect creation and updates are efficient
- Untracking can provide significant performance benefits for large operations

You can run the benchmarks with:

```
v -enable-globals -stats test src/reactive/reactive_benchmark_test.v
```

## Roadmap

- [ ] Implement `createMemo` for memoized values
- [ ] Add `batch` for batching updates
- [ ] Implement `on` for explicit dependency tracking
- [ ] Add `createResource` for async data fetching
- [ ] Implement `createDeferred` for deferred updates
- [ ] Add JSX-like syntax for V UI libraries

## Contributing

Contributions are welcome! Here's how you can help:

1. Implement missing features from SolidJS
2. Improve performance
3. Add more tests and examples
4. Improve documentation
5. Report bugs and suggest features

## License

MIT
