defmodule Shrtnr.HTML do
  @moduledoc false

  def render(assigns \\ []) do
    path = Path.join(:code.priv_dir(:shrtnr), "template.html.eex")
    EEx.eval_file(path, assigns: assigns)
  end
end
