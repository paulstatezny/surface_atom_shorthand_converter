defmodule Mix.Tasks.Surface.ConvertAtomStringShorthand do
  use Mix.Task

  def run(args) do
    {_, [directory]} = OptionParser.parse!(args, strict: [])
    File.cd!(directory)
    compile_and_maybe_repair(directory)
  end

  def compile_and_maybe_repair(directory) do
    with {:error, %{status: 1, err: errors}} <- Rambo.run("mix", ["compile", "--force", "--warnings-as-errors"], cd: directory) do
      ~r/warning: automatic conversion of string literals into atoms is deprecated and will be removed in v0.5.0.\n\nHint: replace `(.*)` with `(.*)`\n\n  (.*):(.*):/
      |> Regex.scan(errors, capture: :all_but_first)
      |> Enum.each(&repair/1)
    end

    IO.puts "✅ Finished"
  end

  defp repair([find, replace, filepath, line_number]) do
    line_number = String.to_integer(line_number)

    updated =
      filepath
      |> File.read!()
      |> String.split("\n")
      |> List.update_at(line_number - 1, fn line_contents ->
        String.replace(line_contents, find, replace)
      end)
      |> Enum.join("\n")

    File.write!(filepath, updated)
  end
end
