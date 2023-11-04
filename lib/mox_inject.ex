defmodule MoxInject do
  @moduledoc """
  Maps between modules, the behaviours they implement, and the modules which
  are substituted for them in the test environment.

      use MoxInject do
        alias MODULE, as: @ATTR
        ...
      end

  This will assign each dependency, or its test substitute, to the given module
  attribute.

  We usually prefer to use the alias from `MoxInject` as that has our
  mocked functions. However, if we need to use the module as a type such as in
  specs, default arguments and new structures, we need to use the original alias.

  In this case, we can have two aliases for the same module in the same file,
  one is used for the type references and the other is used for the mocked
  function calls. For instance, we can have the following:

      alias Phoenix.LiveView.JS

      use MoxInject do
        alias Phoenix.LiveView.JS, as: @js
      end

      defp hide_modal(js \\ %JS{}, selector) do
        js
        |> @js.hide(...)
      end
  """

  defmacro __using__(do_block) do
    for alias_stmt <- block_lines(do_block) do
      {module, alias_name} = alias_opts(alias_stmt)

      quote do
        Module.put_attribute(
          __MODULE__,
          unquote(alias_name),
          unquote(actual_dependency(module))
        )
      end
    end
  end

  defp block_lines(do: {:__block__, _, lines}), do: lines
  defp block_lines(do: line), do: [line]
  defp block_lines(_), do: raise_err("expected a do block")

  defp alias_opts({:alias, _, [module | opts]}) do
    alias_name =
      case opts do
        [[as: attribute]] -> attribute_name(attribute)
        found -> raise_err("alias statements must provide an :as clause", found)
      end

    {module_name(module), alias_name}
  end

  defp alias_opts(found), do: raise_err("expected an alias statement", found)

  defp module_name({:__aliases__, _, module_parts}) when is_list(module_parts),
    do: Module.concat(module_parts)

  defp module_name(found), do: raise_err("expected a module name", found)

  defp attribute_name({:@, _, [{attribute_name, _, nil}]}) when is_atom(attribute_name),
    do: attribute_name

  defp attribute_name(found), do: raise_err("aliases must be module attributes", found)

  @dialyzer {:no_return, raise_err: 1, raise_err: 2}
  defp raise_err(message, []), do: raise_err(message)
  defp raise_err(message, ast), do: raise_err(message <> ", got: '#{Macro.to_string(ast)}'")
  defp raise_err(message), do: raise("#{__MODULE__}: #{message}")

  #

  defp actual_dependency(module) do
    if Application.get_env(:mox_inject, :test_dependencies?, false),
      do: test_dependency(module),
      else: module
  end

  defp test_dependency(module) do
    test_dependencies()[module] || raise "#{module} not in dependency mapping for tests"
  end

  defp test_dependencies do
    for {module, _behaviours} <- modules_and_behaviours(),
        into: %{},
        do: {module, Module.concat(module, Mock)}
  end

  @spec modules_and_behaviours :: [{module(), module()}]
  def modules_and_behaviours do
    Enum.concat(
      Application.get_env(:mox_inject, :explicit_behaviours, %{}) |> Map.to_list(),
      Application.get_env(:mox_inject, :modules_with_behaviour_submodules, [])
      |> Enum.map(&{&1, :in_submodule})
    )
    |> Enum.map(fn {module, behaviours} ->
      {module, normalize_behaviours(behaviours, module)}
    end)
  end

  defp normalize_behaviours(behaviours, module) do
    behaviours
    # Can be specified as a single behaviour or a list of behaviours
    |> List.wrap()
    |> Enum.map(fn
      :in_submodule -> Module.concat(module, Behaviour)
      behaviour -> behaviour
    end)
  end
end
