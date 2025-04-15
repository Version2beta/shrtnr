defmodule Shrtnr.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :slug, :string, null: false
      add :original_url, :string, null: false
      add :visit_count, :integer, default: 0, null: false

      timestamps()
    end

    create unique_index(:links, [:slug])
  end
end
