defmodule WerdleWeb.WordLive.Index do
  use WerdleWeb, :live_view

  alias Werdle.{WordBank, Game}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:solve, WordBank.random_solve())
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
      {:correct, _changeset} <- Game.check_guess_correctness(changeset, guess_row, solve.name) do
      {:noreply, handle_correct_guess(socket)}

    else
      {:error, error_message} ->
        {:noreply, handle_invalid_guess(socket, error_message)}

      {:incorrect, _changeset} when guess_row == 5 ->
        {:noreply, handle_game_over(socket)}

      {:incorrect, _changeset} ->
        {:noreply, handle_incorrect_guess(socket)}

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

  defp handle_correct_guess(socket) do
    create_guess_response(socket, "#{String.upcase(socket.assigns.solve.name)} is correct!")
  end

  defp handle_invalid_guess(socket, error_message) do
    socket
    |> push_event("shake-row", %{id: socket.assigns.current_guess})
    |> push_event("guess-validation-text", %{message: error_message})
  end

  defp handle_game_over(socket) do
    socket
    |> create_guess_response("#{String.upcase(socket.assigns.solve.name)} was the correct answer.")
    |> push_event("shake-row", %{id: socket.assigns.current_guess})
  end

  defp handle_incorrect_guess(socket) do
    socket
    |> create_guess_response(nil)
    |> assign(:current_guess, socket.assigns.current_guess + 1)
    |> push_event("shake-row", %{id: socket.assigns.current_guess})
  end

  defp create_guess_response(socket, message) do
    guess_row = socket.assigns.current_guess
    comparison_results =
      Game.compare_guess(socket.assigns.changeset, guess_row, socket.assigns.solve.name)
    letter_statuses =
      Enum.map(comparison_results, fn {_letter, letter_status} -> letter_status end)

    socket
    |> maybe_push_event("guess-validation-text", message)
    |> push_event("guess-reveal-animation", %{
      guess_row: guess_row,
      letter_statuses: letter_statuses,
      comparison_results: Map.new(comparison_results)
    })
  end

  defp maybe_push_event(socket, nil, _), do: socket
  defp maybe_push_event(socket, event, message) do
    push_event(socket, event, %{message: message})
  end
end
