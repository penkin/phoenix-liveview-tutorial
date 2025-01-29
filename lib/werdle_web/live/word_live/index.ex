defmodule WerdleWeb.WordLive.Index do
  use WerdleWeb, :live_view

  alias Werdle.Game

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:cell_backgrounds, %{})
      |> assign(:keyboard_backgrounds, %{})
      |> assign(:changeset, Game.change_guesses())
      |> assign(:current_guess, 0)

    {:ok, socket}
  end

  @impl true
  def handle_event("backspace", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("enter", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("letter", %{"key" => key}, socket) do
    changeset = socket.assigns.changeset
    guess_row = socket.assigns.current_guess

    IO.inspect(changeset)

    if Game.five_char_guess?(changeset, guess_row) do
      {:noreply, socket}
    else
      socket = assign(socket, :changeset, Game.update_guesses(changeset, key, guess_row))
      {:noreply, socket}
    end
  end
end
