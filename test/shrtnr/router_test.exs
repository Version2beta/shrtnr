defmodule Shrtnr.RouterTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn
  alias Shrtnr.{Repo, Link}

  @opts Shrtnr.Router.init([])

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "POST / creates a shortened link" do
    conn =
      conn(:post, "/", "url=https://example.com")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> Shrtnr.Router.call(@opts)

    assert conn.status == 201
    assert conn.resp_body =~ "Shortened:"
    assert conn.resp_body =~ ~r|http://www\.example\.com:80/\w{6}|

    slug =
      Regex.run(~r|http://www\.example\.com:80/(\w{6})|, conn.resp_body, capture: :all_but_first)
      |> List.first()

    assert is_binary(slug)
    assert %Link{} = Link.get_by_slug(slug)
  end

  test "GET /:slug redirects to original URL" do
    {:ok, link} = Link.create_with_generated_slug(%{original_url: "https://redirect.com"})

    conn =
      conn(:get, "/#{link.slug}")
      |> Shrtnr.Router.call(@opts)

    assert conn.status == 302
    assert get_resp_header(conn, "location") == [link.original_url]
  end

  test "GET /notfound returns 404" do
    conn = conn(:get, "/doesnotexist") |> Shrtnr.Router.call(@opts)
    assert conn.status == 404
  end

  test "GET /stats returns HTML with known links" do
    {:ok, link1} = Link.create_with_generated_slug(%{original_url: "https://a.com"})
    {:ok, link2} = Link.create_with_generated_slug(%{original_url: "https://b.com"})

    conn = conn(:get, "/stats") |> Shrtnr.Router.call(@opts)

    assert conn.status == 200
    assert conn.resp_body =~ link1.slug
    assert conn.resp_body =~ link2.original_url
    assert conn.resp_body =~ "/stats.csv"
  end

  test "GET /stats.csv returns CSV content" do
    {:ok, link} = Link.create_with_generated_slug(%{original_url: "https://csv.com"})

    conn = conn(:get, "/stats.csv") |> Shrtnr.Router.call(@opts)

    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["text/csv; charset=utf-8"]
    assert conn.resp_body =~ "slug,original_url,visit_count"
    assert conn.resp_body =~ link.slug
  end
end
