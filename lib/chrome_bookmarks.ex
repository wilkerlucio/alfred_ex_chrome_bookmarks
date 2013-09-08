defmodule ChromeBookmarks do
  defrecord Bookmark, name: nil, url: nil

  def main do
    query = System.get_env("QUERY")

    bookmarks_from_file("/Users/wilkerlucio/Library/Application Support/Google/Chrome/Default/Bookmarks")
    |> search_bookmarks(query)
    |> output
  end

  defp output(bookmarks) do
    IO.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    IO.puts "<items>"
    Enum.each bookmarks, fn(b) ->
      IO.puts "<item arg=\"#{b.url}\">"
      IO.puts "<title>#{String.slice b.name, 0, 79}</title>"
      IO.puts "<subtitle>#{b.url}</subtitle>"
      IO.puts "</item>"
    end
    IO.puts "</items>"
  end

  def bookmarks_from_file(path) do
    json = parse_json_file(path)
    roots = ListDict.get json, "roots"
    extract_bookmarks(roots, [])
  end

  defp parse_json_file(path) do
    case File.read path do
      {:ok, binary} -> Jsonex.decode(binary)
    end
  end

  defp extract_bookmarks([], acc), do: acc

  defp extract_bookmarks([{_, head}|tail], acc) when is_list(head) do
    extract_bookmarks([head | tail], acc)
  end

  defp extract_bookmarks([{_, _}|tail], acc), do: extract_bookmarks(tail, acc)

  defp extract_bookmarks([head|tail], acc) do
    type = ListDict.get(head, "type") || ListDict.get(head, "TYPE")

    if is_binary(type) do
      extract_bookmarks(tail, head, String.downcase(type), acc)
    else
      extract_bookmarks(tail, acc)
    end
  end

  defp extract_bookmarks(tail, item, "folder", acc) do
    children = ListDict.get item, "children", []
    extract_bookmarks(tail, extract_bookmarks(children, acc))
  end

  defp extract_bookmarks(tail, bookmark, "url", acc) do
    name = ListDict.get bookmark, "name"
    url = ListDict.get bookmark, "url"
    item = Bookmark[name: name, url: url]

    extract_bookmarks(tail, [item | acc])
  end

  def search_bookmarks(bookmarks, query) do
    {:ok, expr} = fuzzy_regexp(String.codepoints(query), "")

    lc b inlist bookmarks, Regex.match?(expr, b.name), do: b
  end

  defp fuzzy_regexp([], query) do
    Regex.compile(query, "i")
  end

  defp fuzzy_regexp([head|tail], query) do
    fuzzy_regexp(tail, query <> Regex.escape(head) <> ".*")
  end
end
