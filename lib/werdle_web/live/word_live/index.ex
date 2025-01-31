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
      {:noreply, handle_correct_guess(socket, solve)}
    else
      {:error, error_message} ->
        {:noreply, handle_invalid_guess(socket, error_message)}

      {:incorrect, _changeset}  when guess_row == 5 ->
        {:noreply, handle_game_over(socket, solve)}

      {:incorrect, _changeset} ->
        socket = assign(socket, :current_guess, guess_row + 1)
        {:noreply, handle_incorrect_guess(socket, guess_row)}
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

  defp handle_correct_guess(socket, solve) do
    socket
    |> push_event("guess-validation-text", %{message: "#{String.upcase(solve.name)} is correct!"})
  end

  defp handle_invalid_guess(socket, error_message) do
    socket
    |> push_event("shake-row", %{id: socket.assigns.current_guess})
    |> push_event("guess-validation-text", %{message: error_message})
  end

  defp handle_game_over(socket, solve) do
    socket
    |> push_event("shake-row", %{id: socket.assigns.current_guess})
    |> push_event("guess-validation-text", %{message: "#{String.upcase(solve.name)} was the correct answer."})
  end

  defp handle_incorrect_guess(socket, guess_row) do
    socket
    |> assign(:current_guess, guess_row + 1)
    |> push_event("shake-row", %{id: socket.assigns.current_guess})
    |> push_event("guess-validation-text", %{message: "Try again."})
  end
end
