defmodule MoxInject.Test do
  @moduledoc """
  Functions invoked during test setup.
  """

  @spec setup_mocks(module) :: :ok
  def setup_mocks(mock_module) do
    for {module, behaviours} <- MoxInject.modules_and_behaviours() do
      mock_module.defmock(Module.concat(module, Mock), for: behaviours)
    end

    :ok
  end
end
