defmodule WerdleWeb.GameBoard.RowComponent do
  @moduledoc """
  Live component for rendering a row of cells in the game board.
  """

  use WerdleWeb, :live_component

  @impl true
  def update(%{id: id, row_index: row_index, changeset: changeset}, socket) do
    socket = socket
    |> assign(:id, id)
    |> assign(:row_index, row_index)
    |> assign(:changeset, changeset)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="col-span-1 gap-1.5 flex justify-items-center justify-center">
      <%= for column_index <- 0..4 do %>
        <.live_component
          module={WerdleWeb.GameBoard.CellComponent}
          id={"input-cell-#{@row_index}-#{column_index}"}
          changeset={@changeset} />
      <% end %>
    </div>
    """
  end
end
