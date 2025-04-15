defmodule Shrtnr.Link do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Shrtnr.{Link, Repo}

  schema "links" do
    field(:slug, :string)
    field(:original_url, :string)
    field(:visit_count, :integer, default: 0)
    timestamps()
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:slug, :original_url])
    |> validate_required([:slug, :original_url])
    |> validate_format(
      :original_url,
      ~r/^https?:\/\/(?:(?:localhost|\d{1,3}(?:\.\d{1,3}){3})(?::\d+)?|(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]+\.[a-zA-Z]{2,})(?:\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?$/
    )
    |> unique_constraint(:slug)
  end

  def create(attrs) do
    %Link{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def create_with_generated_slug(attrs, gen_slug \\ &Shrtnr.Slug.generate/0, attempt \\ 1)

  def create_with_generated_slug(attrs, gen_slug, attempt) when attempt <= 5 do
    slug = gen_slug.()

    case create(Map.put(attrs, :slug, slug)) do
      {:ok, link} ->
        {:ok, link}

      {:error, %Ecto.Changeset{errors: [slug: {"has already been taken", _}]}} ->
        create_with_generated_slug(attrs, gen_slug, attempt + 1)

      other ->
        other
    end
  end

  def create_with_generated_slug(_attrs, _gen_slug, _attempt),
    do: {:error, :slug_generation_failed}

  def get_by_slug(slug), do: Repo.get_by(Link, slug: slug)

  def increment_visit_count(%Link{} = link) do
    from(l in Link, where: l.id == ^link.id)
    |> Repo.update_all(inc: [visit_count: 1])
  end

  def all do
    # Note this assumes monotonically increasing IDs
    from(l in Link, order_by: [desc: l.inserted_at, desc: l.id])
    |> Repo.all()
  end
end
