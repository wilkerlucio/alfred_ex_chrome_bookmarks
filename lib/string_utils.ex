defmodule StringUtils do
  def parameterize(string) do
    parameterized = Regex.replace(%r/[^a-z0-9_-]+/i, string, "-")
    Regex.replace(%r/-{2,}/, parameterized, "-")
    |> String.strip(?-)
    |> String.downcase
  end
end
