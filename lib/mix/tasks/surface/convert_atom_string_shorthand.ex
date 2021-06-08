defmodule Mix.Tasks.Surface.ConvertAtomStringShorthand do
  use Mix.Task

  def run(args) do
    {_, [directory]} = OptionParser.parse!(args, strict: [])
    File.cd!(directory)
    compile_and_maybe_repair(directory)
  end

  def compile_and_maybe_repair(directory) do
    case System.cmd("mix", ["compile"], cd: directory) do
      {message, 1} ->
        case Regex.run(~r/\(CompileError\) (.*):(\d+): invalid value for property "(.*)". Expected a :atom, got: "(.*)"/, message) do
          [_match, filepath, line, prop, value] ->
            repair(filepath, String.to_integer(line), prop, value)
            #compile_and_maybe_repair(directory)

          nil ->
            IO.puts "☠️ Crashed with message:\n\n#{message}"
        end

      {_, 0} ->
        IO.puts "✅ Finished"
    end
  end

  defp repair(filepath, line_number, prop, value) do
    updated =
      filepath
      |> File.read!()
      |> String.split("\n")
      |> List.update_at(line_number - 1, fn line ->
        String.replace(line, "#{prop}=\"#{value}\"", "#{prop}={:#{value}}")
      end)
      |> Enum.join("\n")
      |> IO.inspect()

    File.write!(filepath, updated)
  end
end
