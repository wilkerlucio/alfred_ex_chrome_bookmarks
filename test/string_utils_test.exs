Code.require_file "test_helper.exs", __DIR__

defmodule StringUtilsTest do
  import StringUtils

  use ExUnit.Case, async: true

  test "parameterize a string" do
    assert parameterize("Amazon.com: Audio - Speaker / Headset Switching Hub,") == "amazon-com-audio-speaker-headset-switching-hub"
  end
end
