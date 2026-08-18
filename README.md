# Phlex::Stimulus

`phlex-stimulus` pairs every [Stimulus](https://stimulus.hotwired.dev/) controller in your app with a
[Phlex](https://www.phlex.fun/) component, and keeps both sides strictly typed.

For each Stimulus controller (the TypeScript side) there is a matching Phlex component
(the Ruby side). The component owns the markup that mounts the controller — the `data-controller`
attribute, its targets, actions, and values — and exposes strictly [Sorbet](https://sorbet.org/)-typed
helpers so the wiring between Ruby and JS can't silently drift.

Controllers can also be **chained**: a set of controllers can be rendered so that each one's `connect`
logic runs to completion before the next one connects.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add phlex-stimulus
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install phlex-stimulus
```

Then run the installer.

```sh
bundle exec rails generate phlex:stimulus:install
```

## Usage

### Generating a controller + component

```sh
bundle exec rails generate phlex:stimulus:controller Summary
```

This creates a matched pair:

- `app/components/summary_controller.rb` — a `Components::SummaryController`
- `app/javascript/controllers/summary_controller.ts` — a `SummaryController`

### Ruby controller components

A controller component declares the Stimulus controller name, its actions, and its targets. Those
declarations generate strictly-typed helpers so your markup references controllers, actions, and targets
by method call instead of by hand-written string:

```ruby
# typed: strict

module Components
  class SummaryController < Controller
    self.controller_name = 'summary'

    actions :redirect          # => defines SummaryController.redirect_action  #=> "summary#redirect"
    action :loadItem do # defines an action with action parameters
      param :id # required action parameter
      param :async, optional: true # optional action parameter
    end
    targets :body              # => defines SummaryController.body_target       #=> "body"

    #: (title: String) -> void
    def initialize(title:)
      @title = title
    end

    # @override
    #: ?{ -> void } -> void
    def view_template(&block)
      div(data: { controller: self.class.controller_name, title: @title }) do
        block&.call
      end
    end

  end
end
```

You can render a controller like any other Phlex component:

```ruby
render SummaryController.new(title: 'Report') do
  # define an action with parameters
  button(data: merge(SummaryController.load_item_on('click', id: '25'), other: 'data')) { 'Go' }

  # define an action without param checking
  button(data: { action: event('click', SummaryController.redirect_action) }) { 'Go' }

  # define a target
  div(data: merge(SummaryController.body_target_anchor, other: "data")) do
    plan "Foo"
  end
end
```

This is the same as:

```rb
div(data: { controller: 'summary', title: 'Report' }) do
  # define an action with parameters
  button(data: { action: 'click->summary#loadItem', 'summary-id-param' => '25', other: 'data' }) { 'Go' }

  # define an action
  button(data: { action: 'click->summary#redirect', other: 'data' }) { 'Go' }

  # define a target
  div(data: { 'summary-target' => 'body', other: 'data' }) do
    plan "Foo"
  end
end
```

### Controller component helpers

#### `_on`

Each action you define will result in a corresponding `_on` method being available in Ruby.
Sorbet is fully aware of these methods thanks to a tapioca compiler.

These methods return an anchor hash that can be used as a value in `data:` to attach the
action with parameters to a DOM event on a particular DOM element.

You can read more about actions [here](https://stimulus.hotwired.dev/reference/actions).

```rb
class SummaryController < Controller
  self.controller_name = 'summary'

  actions :exit

  action :loadItem do
    param :id
    param :async, optional: true
  end
end

SummaryController.exit_on('click') #=> { action: "click->summary#exit" }
SummaryController.load_item_on('click', id: "25") #=> { action: "click->summary#loadItem", "summary-id-param" => "25" }
SummaryController.load_item_on('click', id: "25", async: "true") #=> { action: "click->summary#loadItem", "summary-id-param" => "25", "summary-async-param" => "true" }
```

This can be used to attach an action to an HTML element with full type safety including action params.

```rb
div(data: SummaryController.exit_on('click'))
div(data: merge(SummaryController.load_item_on('click', id: "69"), other: "data"))
```

This is the same as:

```rb
div(data: { action: 'click->summary#exit' })
div(data: { action: 'click->summary#loadItem', 'summary-id-param' => '69', other: 'data' })
```

#### `_action`

Each action you define will result in a corresponding `_action` method being available in Ruby.
Sorbet is fully aware of these methods thanks to a tapioca compiler.

These methods just return the name of the controller together with the name of the action: `"controller#action"`.
They mostly exist so that sorbet can check if the actions your using when building HTML elements
actually exist.

You can read more about actions [here](https://stimulus.hotwired.dev/reference/actions).

```rb
class SummaryController < Controller
  self.controller_name = 'summary'

  actions :foo
end

SummaryController.foo_action #=> "summary#foo"
```

This can be used to attach an action to an HTML element with full type safety.

```rb
div(data: { action: event('click', SummaryController.foo_action) })
```

This is the same as:

```rb
div(data: { action: 'click->summary#foo' })
```

#### `_target_anchor`

Each target you define will result in a corresponding `_target_anchor` method being available in Ruby.
Sorbet is fully aware of these methods thanks to a tapioca compiler.

These methods return a hash that can be used to attach the target.

You can read more about targets [here](https://stimulus.hotwired.dev/reference/targets).

```rb
class SummaryController < Controller
  self.controller_name = 'summary'

  targets :foo
end

SummaryController.foo_target_anchor #=> { "summary-target" => "foo" }
```

You would use it like so to attach a target with full type safety:

```rb
div(data: SummaryController.foo_target_anchor)
```

This is the same as:

```rb
div(data: { 'summary-target' => 'foo' })
```

You can use `merge` to add other keys alongside the anchor to `data`.

```rb
div(data: merge(SummaryController.foo_target_anchor, bar: 'elo'))
```

This is the same as:

```rb
div(data: { 'summary-target' => 'foo', bar: 'elo' })
```


#### `target_key`

This method returns the key that can be used to attach targets to the controller.

```rb
class SummaryController < Controller
  self.controller_name = 'summary'

  targets :foo
end

SummaryController.target_key #=> "summary-target"
```

You would use it like so to attach a target with full type safety:

```rb
div(data: { SummaryController.target_key => SummaryController.foo_target })
```

This is the same as:

```rb
div(data: { 'summary-target' => 'foo' })
```

#### `_target`

Each target you define will result in a corresponding `_target` method being available in Ruby.
Sorbet is fully aware of these methods thanks to a tapioca compiler.

These methods just return the name of the target so they may seem pointless.
They exist only so that sorbet can check if the actions your using when building HTML elements
actually exist.

You can read more about targets [here](https://stimulus.hotwired.dev/reference/targets).

```rb
class SummaryController < Controller
  self.controller_name = 'summary'

  targets :foo
end

SummaryController.foo_target #=> "foo"
```

You would use it like so to attach a target with full type safety:

```rb
div(data: { SummaryController.target_key => SummaryController.foo_target })
```

This is the same as:

```rb
div(data: { 'summary-target' => 'foo' })
```

#### `dispatched`

This method helps you get the names of custom events dispatched by a stimulus controller.
You can read more about event dispatching [here](https://stimulus.hotwired.dev/reference/controllers#cross-controller-coordination-with-events).

```rb
class SummaryController < Controller
  self.controller_name = 'summary'
end

SummaryController.dispatched('redirected') #=> "summary:redirected"
```

You would use it like so to define an action on an dispatched event:

```rb
div(data: { action: event(SummaryController.dispatched('redirected'), OtherController.do_action) })
```

This is the same as:

```rb
div(data: { action: 'summary:redirected->other#do' })
```

#### `param`

This method helps you get the names of parameters
given to stimulus actions.
You can read more about action parameters [here](https://stimulus.hotwired.dev/reference/https://stimulus.hotwired.dev/reference/actions#action-parameters).

```rb
class SummaryController < Controller
  self.controller_name = 'summary'

  actions :foo
end

SummaryController.param('id') #=> "summary-id-param"
```

You would use it like so to define a parameter for a stimulus action:

```rb
div(
  data: {
    action: event('click', SummaryController.foo_action),
    # will be available as `event.id` in the action
    SummaryController.param('id') => '35',
  },
)
```

This is the same as:

```rb
div(
  data: {
    action: 'click->summary#foo',
    'summary-id-param' => '35',
  },
)
```

### Component Helpers

There are some useful helper methods you can use in every phlex component.

#### `attrbool`

`attrbool` converts a Ruby boolean to `'true'` or `nil` so the boolean value
can be used in attributes of HTML elements

```rb
attrbool(true) #=> "true"
attrbool(false) #=> nil
```

You would use it when passing a boolean value from Ruby to an HTML attribute.

```rb
button(data: { enabled: attrbool(@enabled) })
```

#### `event`

`event` let's you easily and safely create stimulus action strings.

```rb
event('click', 'summary#redirect') #=> "click->summary#redirect"
event('click', SummaryController.redirect_action) #=> "click->summary#redirect"
```

You would use it when attaching a controller action to some HTML element.

```rb
button(data: { action: event('click', SummaryController.redirect_action) })
```

#### `class_list`

`class_list` let's you easily add classes to html elements conditionally.

```rb
class_list("foo", "bar", "baz") #=> "foo bar baz"

error = false
class_list("foo", "red" if error, "bar") #=> "foo bar"

error = true
class_list("foo", "red" if error, "bar") #=> "foo red bar"
```

You would use it when declaring an HTML element.

```rb
div(class: class_list("foo", "red" if error, "bar")) do
  plain "Hello!"
end
```

`class_list` is aliased as `strlist` as it may be useful for other things than CSS classes.

### Stimulus controllers

There is a `TypedController` factory that let's you define strict types for controller targets.

```ts
import { application } from "./application"
import { TypedController } from "./typed_controller"

class SummaryController extends TypedController<HTMLElement, { body: HTMLDivElement }>() {
  static targets = ["body"]

  redirect() {
    this.bodyTarget.innerText = "…"   // fully typed
  }
}

application.register("summary", SummaryController)
```

### Chaining controllers

Sometimes controllers must connect in a specific order — each one finishing its setup before the next
starts. `phlex-stimulus` supports this on both sides.

On the TypeScript side, a chainable controller extends `ChainableController` (or
`TypedChainableController` for typed targets) and puts its `connect` logic in `init()`. When `init()`
resolves, the controller dispatches a `ready` event that the chain waits on:

```ts
class LogController extends ChainableController<HTMLElement> {
  async init() {
    console.log("connected")
  }
}
```

On the Ruby side, render your controller components through `Components::ControllerChain`. It renders
each controller inside a deferred `<template>` and drives them via the `chain` controller so they attach
one after another:

```ruby
render Components::ControllerChain.new(
  Components::SleepController.new(timeout: 500),
  Components::LogController.new(message: "ready!"),
)
```

This would result in a *"ready!"* console message getting displayed after 500 milliseconds.

Two of the bundled controllers are especially useful as chain building blocks:

- `Components::SleepController.new(timeout:)` — pauses the chain for the given number of milliseconds.
- `Components::LogController.new(message:, on_event:)` — `console.log`s a message when it connects
  (handy for debugging a chain).

You can look those up as examples to see how you can implement your own chainable controllers.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/espago/phlex-stimulus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/espago/phlex-stimulus/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
