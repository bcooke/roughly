defmodule Roughly.Architecture.ContractsTest do
  use ExUnit.Case, async: true

  @roots ~w(lib/roughly/access lib/roughly/questions lib/roughly/identity lib/roughly/participation)
  test "commands, events and aggregate states publish complete struct types" do
    files = Enum.flat_map(@roots, &Path.wildcard("#{&1}/**/*.ex"))

    modules =
      for file <- files,
          Regex.match?(
            ~r{/(commands|events)/|/(questions/(question|slug)|participation/response|identity/principal|access/grants)\.ex$},
            file
          ),
          do: module_for(file)

    assert length(modules) > 20

    for module <- modules do
      assert {:ok, types} = Code.Typespec.fetch_types(module), "#{inspect(module)} has no types"

      assert {:type, {:t, {:type, _, :map, fields}, []}} =
               Enum.find(types, fn {_, {name, _, _}} -> name == :t end),
             "#{inspect(module)} lacks a struct contract"

      names =
        for {:type, _, :map_field_exact, [{:atom, _, key}, _]} <- fields,
            key != :__struct__,
            do: key

      assert Enum.sort(names) ==
               module.__struct__() |> Map.from_struct() |> Map.keys() |> Enum.sort()
    end
  end

  test "named queries and domain facades declare public input and result contracts" do
    files =
      Path.wildcard("lib/roughly/analysis/queries/*.ex") ++
        Path.wildcard("lib/roughly/questions/queries/*.ex") ++
        ~w(lib/roughly/questions.ex lib/roughly/identity.ex lib/roughly/participation.ex lib/roughly/access.ex)

    for file <- files do
      module = module_for(file)

      assert {:ok, specs} = Code.Typespec.fetch_specs(module),
             "#{inspect(module)} has no query contracts"

      specified = Enum.map(specs, &elem(&1, 0)) |> MapSet.new()

      for {name, arity} <- module.__info__(:functions), name not in [:__struct__] do
        # Elixir default-argument forwarding functions share the full-arity contract.
        assert Enum.any?(specified, fn {spec_name, spec_arity} ->
                 spec_name == name and spec_arity >= arity
               end),
               "#{inspect(module)}.#{name}/#{arity} has no contract"
      end
    end
  end

  test "production command dispatch has one actor-aware seam" do
    files = Path.wildcard("{lib,dev}/**/*.ex")
    assert files != []

    offenders =
      files
      |> Enum.reject(&(&1 == "lib/roughly/dispatch.ex"))
      |> Enum.filter(&(File.read!(&1) =~ ~r/\bApp\.dispatch\(/))

    assert offenders == []
  end

  defp module_for(file) do
    [_, name] = Regex.run(~r/defmodule\s+([\w.]+)/, File.read!(file))
    Module.safe_concat(String.split(name, "."))
  end
end
