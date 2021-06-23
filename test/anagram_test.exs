defmodule TestAnagram do
  use ExUnit.Case

  test "anagram?" do
    assert Anagram.anagrams?("showwin", "winwsho") == true
    assert Anagram.anagrams?("showwin", "hello") == false
  end
end
