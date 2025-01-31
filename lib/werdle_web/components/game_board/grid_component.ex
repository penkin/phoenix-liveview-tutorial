defmodule WerdleWeb.GameBoard.GridComponent do
  @moduledoc """
  Live component for rendering the game board grid in the Werdle web application.
  """

  use WerdleWeb, :live_component

  @impl true
  @spec update(
          %{
            :cell_backgrounds => any(),
            :changeset => any(),
            :id => any(),
            optional(any()) => any()
          },
          map()
        ) :: {:ok, map()}
  def update(%{id: id, changeset: changeset}, socket) do
    socket = socket
    |> assign(:id, id)
    |> assign(:changeset, changeset)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div id={@id}
           phx-hook="ShakeRowAnimation"
           phx-target={@myself}
           class="grid grid-cols-1 self-start mt-5 mb-5 gap-y-1">
        <div class="grid grid-cols-1 col-span-1 gap-1.5">
          <%= for row_index <- 0..5 do %>
            <.live_component
              module={WerdleWeb.GameBoard.RowComponent}
              id={"input-row-#{row_index}"}
              row_index={row_index}
              changeset={@changeset} />
          <% end %>
        </div>
      </div>
    """
  end
end
