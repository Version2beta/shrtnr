defmodule Shrtnr.Benchmark do
  require Logger
  alias HTTPoison

  @port Application.compile_env(:shrtnr, :port, 8080)
  @url "http://localhost:#{@port}"


  def run do
    Logger.remove_backend(:console)
    Logger.add_backend(:console)

    Logger.configure_backend(:console,
      metadata_filter: [domain: :benchmark],
      metadata: [:domain]
    )

    Logger.configure(level: :info)
    Enum.each([10, 100, 1000], &run_round/1)
  end

  defp run_round(n) do
    Logger.info("Round with #{n} POST + GET ops", domain: :benchmark)

    {post_us, slugs} =
      :timer.tc(fn ->
        1..n
        |> Task.async_stream(&do_post/1, max_concurrency: 50, timeout: 5_000)
        |> Enum.flat_map(fn
          {:ok, {:ok, slug}} ->
            [slug]

          {:ok, {:error, reason}} ->
            Logger.error("POST failed: #{inspect(reason)}", domain: :benchmark)
            []

          _ ->
            []
        end)
      end)

    get_slugs = Enum.flat_map(slugs, fn slug -> List.duplicate(slug, :rand.uniform(10)) end)

    {get_us, get_successes} =
      :timer.tc(fn ->
        get_slugs
        |> Task.async_stream(&measure_get/1, max_concurrency: 100, timeout: 5_000)
        |> Enum.flat_map(fn
          {:ok, {:ok, _ms}} ->
            [1]

          {:ok, {:error, reason}} ->
            Logger.error("GET failed: #{inspect(reason)}", domain: :benchmark)
            []

          _ ->
            []
        end)
      end)

    total_post_time = post_us / 1_000_000
    total_get_time = get_us / 1_000_000
    post_rps = n / max(total_post_time, 0.001)
    get_rps = length(get_successes) / max(total_get_time, 0.001)
    total_rps = (n + length(get_successes)) / max(total_post_time + total_get_time, 0.001)

    Logger.info(
      "Completed #{n} POSTs in #{Float.round(total_post_time, 2)}s (#{Float.round(post_rps, 1)} RPS)",
      domain: :benchmark
    )

    Logger.info(
      "Completed #{length(get_successes)} GETs in #{Float.round(total_get_time, 2)}s (#{Float.round(get_rps, 1)} RPS)",
      domain: :benchmark
    )

    Logger.info(
      "TOTAL: #{n + length(get_successes)} reqs in #{Float.round(total_post_time + total_get_time, 2)}s (#{Float.round(total_rps, 1)} RPS)",
      domain: :benchmark
    )
  end

  defp do_post(i) do
    body = URI.encode_query(%{"url" => "https://example.com/#{i}"})
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    case HTTPoison.post(@url <> "/", body, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        case Regex.run(~r|https?://localhost:\d+/(\w{6})|, body) do
          [_, slug] -> {:ok, slug}
          _ -> {:error, :no_slug}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, {:unexpected_status, code, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp measure_get(slug) when is_binary(slug) do
    url = "#{@url}/#{slug}"

    case :timer.tc(fn -> HTTPoison.get(url) end) do
      {time_us, {:ok, %HTTPoison.Response{status_code: 302}}} ->
        {:ok, div(time_us, 1000)}

      {_, {:ok, %HTTPoison.Response{status_code: code}}} ->
        {:error, {:bad_status, code}}

      {_, {:error, reason}} ->
        {:error, reason}
    end
  end

  defp measure_get(_), do: {:error, :invalid_slug_input}
end

Shrtnr.Benchmark.run()
