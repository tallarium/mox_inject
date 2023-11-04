defmodule MoxInjectTest do
  use ExUnit.Case, async: true

  import Mox

  # See test/test_helper.exs for setup

  setup :verify_on_exit!

  test "mocks modules with a behaviour submodule" do
    MoxInject.MockedModule.Mock
    |> expect(:foo, fn -> :ok end)

    assert MoxInject.TestModule.call_foo() == :ok
  end

  test "mocks modules with a behaviour submodule using an alias" do
    File.Mock
    |> expect(:read, fn _ -> {:ok, "Hello world"} end)

    assert MoxInject.TestModule.call_read("test_file") == {:ok, "Hello world"}
  end
end
