# MoxInject

Maps between modules, the behaviours they implement and their mocks (using Hammox or Mox) in tests:

```elixir
use AnotherModule do
    alias X, as: @x
    ...
    @x.f()
end
```

This will assign each dependency, or its test substitute, to the given module
attribute.

Example:

```elixir
use AnotherModule do
    alias Phoenix.LiveView.JS, as: @js
end

...
@js.hide(...)
...
```

See [Examples](#Examples) and [Configuration](#Configuration) for how to ensure the correct behaviour is located for a given module, so that a mocking library can be used.

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

And in tests:

```elixir
Phoenix.LiveView.JS.Mock
|> expect(:hide, ...)
```

## Examples

Look at `lib/mox_inject/test_module.ex` and `test/mox_inject_test.exs`.

## Configuration

Either the module in question will have a `Behaviour` submodule, as a convention:

```elixir
defmodule X.Behaviour do
    @callback f :: :ok
end

defmodule X do
    @behaviour __MODULE__.Behaviour

    @impl true
    def f do
        ...
    end
end
```

in configuration:

```elixir
config :mox_inject, :modules_with_behaviour_submodules, [X]
```

or, for example, an explicit behaviour can be provided for an existing module.

```elixir
defmodule ExternalBehaviour.PhoenixLiveViewJS do
    @callback ...
end
```

and in configuration:

```elixir
config :mox_inject, :explicit_behaviours, %{
    Phoenix.LiveView.JS => ExternalBehaviour.PhoenixLiveViewJS
}
```

to ensure that the mocking library can find the behaviour for the module.

## Installation

The package can be installed by adding `mox_inject` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mox_inject, "~> 0.1.0"}
  ]
end
```

Documentation and example usage can be found at <https://hexdocs.pm/mox_inject>.
