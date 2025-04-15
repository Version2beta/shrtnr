defmodule Shrtnr.SlugTest do
  use ExUnit.Case, async: true
  alias Shrtnr.Slug

  test "generate/0 returns a 6-character base62 string" do
    slug = Slug.generate()
    assert String.length(slug) == 6
    assert String.match?(slug, ~r/^[0-9A-Za-z]{6}$/)
  end

  test "generate/0 returns different values across calls" do
    slugs = Enum.map(1..100, fn _ -> Slug.generate() end)
    assert Enum.uniq(slugs) == slugs
  end
end
