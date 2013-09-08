Code.require_file "test_helper.exs", __DIR__

defmodule ChromeBookmarksTest do
  use ExUnit.Case, async: true

  alias ChromeBookmarks.Bookmark

  @next Bookmark[name: "Next-Episode", url: "http://next-episode.net/track?mode=Normal"]
  @can Bookmark[name: "Can I Use?", url: "http://caniuse.com/"]

  @bookmarks [@next, @can]

  test "extract bookmarks from a file" do
    assert ChromeBookmarks.bookmarks_from_file("test/fixtures/Bookmarks") == @bookmarks
  end

  test "filtering bookmarks" do
    assert ChromeBookmarks.search_bookmarks(@bookmarks, "ciu") == [@can]
  end

  test "converting bookmarks into alfred output format" do
  end
end
