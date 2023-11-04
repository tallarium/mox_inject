if Mix.env() == :test do
  defmodule MoxInject.MockedModule.Behaviour do
    @callback foo() :: :ok
  end

  defmodule MoxInject.MockedModule do
    @behaviour __MODULE__.Behaviour

    @impl true
    def foo do
      :ok
    end
  end

  defmodule MoxInject.TestModule.FileBehaviour do
    @callback read(String.t()) :: {:ok, String.t()}
  end

  #

  # Required for test setup. This would live in config/ in application code.
  Application.put_env(:mox_inject, :test_dependencies?, true)

  Application.put_env(:mox_inject, :modules_with_behaviour_submodules, [
    MoxInject.MockedModule
  ])

  Application.put_env(:mox_inject, :explicit_behaviours, %{
    File => MoxInject.TestModule.FileBehaviour
  })

  # This would live in test/support/ in application code.
  MoxInject.Test.setup_mocks(Mox)

  #

  defmodule MoxInject.TestModule do
    use MoxInject do
      alias File, as: @file_mock
      alias MoxInject.MockedModule, as: @module
    end

    def call_foo do
      @module.foo()
    end

    def call_read(file) do
      @file_mock.read(file)
    end
  end
end
