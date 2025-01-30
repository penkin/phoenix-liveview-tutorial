defmodule WerdleWeb.WordLive.Index do
  use WerdleWeb, :live_view

  alias Werdle.{WordBank, Game}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:solve, WordBank.random_solve())
      |> assign(:cell_backgrounds, %{})
      |> assign(:keyboard_backgrounds, %{})
      |> assign(:changeset, Game.change_guesses())
      |> assign(:current_guess, 0)

    {:ok, socket}
  end

  @impl true
  def handle_event("backspace", _params, socket) do
    changeset = socket.assigns.changeset
    guess_row = socket.assigns.current_guess

    socket = socket
    |> assign(:changeset, Game.remove_last_character(changeset, guess_row))

    {:noreply, socket}
  end

  def handle_event("enter", _params, socket) do
    changeset = socket.assigns.changeset
    guess_row = socket.assigns.current_guess
    solve = socket.assigns.solve

    with {:ok, _changeset} <- Game.validate_guess(changeset, guess_row),
         {:correct, _changeset} <- Game.check_guess_correctness(changeset, guess_row, solve) do
      {:noreply, socket}
    else
      {:error, _error_message} ->
        {:noreply, socket}

      {:incorrect, _changeset}  when guess_row == 5 ->
        {:noreply, socket}

      {:incorrect, _changeset} ->
        socket = assign(socket, :current_guess, guess_row + 1)
        {:noreply, socket}
    end
  end

  def handle_event("letter", %{"key" => key}, socket) do
    changeset = socket.assigns.changeset
    guess_row = socket.assigns.current_guess

    if Game.five_char_guess?(changeset, guess_row) do
      {:noreply, socket}
    else
      socket = assign(socket, :changeset, Game.update_guesses(changeset, key, guess_row))
      {:noreply, socket}
    end
  end
end
