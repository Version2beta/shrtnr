defmodule Shrtnr.Router do
  use Plug.Router
  import Plug.Conn
  alias Shrtnr.{Link}

  plug(Plug.Parsers,
    parsers: [:urlencoded],
    pass: ["*/*"],
    body_reader: {Plug.Conn, :read_body, []}
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, Shrtnr.HTML.render(%{page: :form}))
  end

  post "/" do
    case conn.body_params do
      %{"url" => original_url} ->
        case Link.create_with_generated_slug(%{original_url: original_url}) do
          {:ok, link} ->
            short_url = "#{conn.scheme}://#{conn.host}:#{conn.port}/#{link.slug}"
            send_resp(conn, 201, Shrtnr.HTML.render(%{page: :shortened, short_url: short_url}))

          {:error, _} ->
            send_resp(conn, 422, "Invalid URL or slug conflict")
        end

      _ ->
        send_resp(conn, 400, "Missing URL")
    end
  end

  get "/stats" do
    links = Link.all()

    rows =
      for link <- links do
        """
        <tr>
          <td><a href="/#{link.slug}">/#{link.slug}</a></td>
          <td><a href="#{link.original_url}">#{link.original_url}</a></td>
          <td>#{link.visit_count}</td>
        </tr>
        """
      end

    html = """
    <html>
      <head><title>Stats</title></head>
      <body>
        <h1>Link Stats</h1>
        <a href="/stats.csv">Download CSV</a>
        <table border="1" cellpadding="4" cellspacing="0">
          <thead>
            <tr><th>Slug</th><th>Original URL</th><th>Visits</th></tr>
          </thead>
          <tbody>
            #{Enum.join(rows, "\n")}
          </tbody>
        </table>
      </body>
    </html>
    """

    send_resp(conn, 200, html)
  end

  get "/stats.csv" do
    links = Link.all()

    csv =
      [
        ["slug", "original_url", "visit_count"]
        | Enum.map(links, fn l -> [l.slug, l.original_url, Integer.to_string(l.visit_count)] end)
      ]
      |> CSV.encode()
      |> Enum.join()

    conn
    |> put_resp_header("content-disposition", "attachment; filename=\"stats.csv\"")
    |> put_resp_content_type("text/csv")
    |> send_resp(200, csv)
  end

  get "/:slug" do
    case Link.get_by_slug(slug) do
      nil ->
        send_resp(conn, 404, "Not found")

      link ->
        Link.increment_visit_count(link)

        conn
        |> put_resp_header("location", link.original_url)
        |> send_resp(302, "")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
