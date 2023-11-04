# MoxInject

Maps between modules, the behaviours they implement, and the modules which
are substituted for them in the test environment.

```elixir
use MoxInject do
    alias MODULE, as: @ATTR
    ...
end
```

This will assign each dependency, or its test substitute, to the given module
attribute.

Example:

```elixir
use MoxInject do
    alias Phoenix.LiveView.JS, as: @js
end

...
@js.hide(...)
...
```

To replace with mocks:

```elixir
if Mix.env() == :test do
    config :mox_inject, test_dependencies?: true
end
```

and add a file `test/support/mocks.ex` - so that this file is compiled (and evaluated) before the test run:

```elixir
MoxInject.Test.setup_mocks(Mox) # or Hammox
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mox_inject` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mox_inject, "~> 0.1.0"}
  ]
end
```

Documentation and example usage can be found at <https://hexdocs.pm/mox_inject>.
