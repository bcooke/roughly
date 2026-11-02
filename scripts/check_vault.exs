# Validate the repository's active note graph without depending on Obsidian or a forge API.
vault = Path.expand("vault")

links = fn file ->
  body = file |> File.read!() |> then(&Regex.replace(~r/```.*?```/s, &1, ""))

  ~r/(?<!!)\[[^\]]+\]\(([^)]+)\)/
  |> Regex.scan(body, capture: :all_but_first)
  |> Enum.map(fn [target] -> target end)
  |> Enum.reject(fn target ->
    URI.parse(target).scheme != nil or String.starts_with?(target, "#")
  end)
  |> Enum.map(fn target ->
    target
    |> String.split("#", parts: 2)
    |> hd()
    |> URI.decode()
    |> Path.expand(Path.dirname(file))
  end)
  |> Enum.uniq()
end

files =
  Path.wildcard("#{vault}/**/*.md")
  |> Enum.reject(fn file ->
    String.contains?(file, "/archive/") or String.contains?(file, "/_meta/templates/")
  end)

missing =
  for file <- files,
      target <- links.(file),
      not File.exists?(target) do
    "#{Path.relative_to_cwd(file)} links to missing #{Path.relative_to_cwd(target)}"
  end

notes = Path.wildcard("#{vault}/*.md") |> Enum.reject(&(Path.basename(&1) == "README.md"))
note_set = MapSet.new(notes)
mapped = Path.wildcard("#{vault}/topics/*.md") |> Enum.flat_map(links) |> MapSet.new()

structure =
  Enum.flat_map(notes, fn file ->
    name = Path.relative_to_cwd(file)
    related = Enum.filter(links.(file), &MapSet.member?(note_set, &1))

    [
      {not String.starts_with?(File.read!(file), "---\ntype: note\n"),
       "#{name} needs note frontmatter"},
      {length(related) < 2, "#{name} needs links to at least two related concept notes"},
      {not MapSet.member?(mapped, file), "#{name} needs an inbound topic-map link"}
    ]
    |> Enum.flat_map(fn {invalid?, message} -> if invalid?, do: [message], else: [] end)
  end)

case missing ++ structure do
  [] ->
    Mix.shell().info(
      "Vault check passed: #{length(notes)} concept notes; active links and topic coverage valid."
    )

  errors ->
    Mix.raise("Vault check failed:\n" <> Enum.map_join(errors, "\n", &("- " <> &1)))
end
