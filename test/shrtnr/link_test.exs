defmodule Shrtnr.LinkTest do
  use ExUnit.Case, async: true
  alias Shrtnr.{Link, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @valid_attrs %{slug: "abc123", original_url: "https://example.com"}

  test "create/1 inserts a link" do
    assert {:ok, %Link{} = link} = Link.create(@valid_attrs)
    assert link.slug == "abc123"
    assert link.original_url == "https://example.com"
    assert link.visit_count == 0
  end

  test "get_by_slug/1 finds a link" do
    {:ok, link} = Link.create(@valid_attrs)
    found = Link.get_by_slug("abc123")
    assert found.id == link.id
  end

  test "increment_visit_count/1 updates visit_count" do
    {:ok, link} = Link.create(@valid_attrs)
    {1, _} = Link.increment_visit_count(link)
    updated = Link.get_by_slug("abc123")
    assert updated.visit_count == 1
  end

  test "create_with_generated_slug/1 retries on slug collision" do
    # Create a known slug to force conflict
    {:ok, _} = Link.create(%{slug: "dup123", original_url: "https://existing.com"})

    # Generator that returns a collision first, then a unique value
    generator =
      Stream.cycle(["dup123", "ok456"])
      |> Enum.take(2)
      |> (fn list ->
            Agent.start_link(fn -> list end, name: :slug_gen)
            fn -> Agent.get_and_update(:slug_gen, fn [h | t] -> {h, t} end) end
          end).()

    {:ok, link} = Link.create_with_generated_slug(%{original_url: "https://new.com"}, generator)
    assert link.slug == "ok456"
  end

  test "all/0 returns links in descending order by inserted_at and id" do
    {:ok, a} = Link.create_with_generated_slug(%{original_url: "https://a.com"})
    {:ok, b} = Link.create_with_generated_slug(%{original_url: "https://b.com"})

    [first, second | _] = Link.all()
    assert first.id == b.id
    assert second.id == a.id
  end
end
