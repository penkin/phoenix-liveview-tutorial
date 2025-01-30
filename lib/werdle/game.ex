defmodule Werdle.Game do
  @moduledoc """
  A module for managing the game state and logic.
  """

  alias Werdle.WordBank
  alias Werdle.Game.Guesses
  alias Ecto.Changeset

  def change_guesses(attrs \\ %{}) do
    Guesses.changeset(attrs)
  end

  def check_guess_correctness(changeset, guess_row, solve) do
    guess_field = guess_field(guess_row)
    guess = Changeset.get_field(changeset, guess_field) |> Enum.join()

    if guess == solve, do: {:correct, changeset}, else: {:incorrect, changeset}
  end

  def validate_guess(changeset, guess_row) do
    guess_field = guess_field(guess_row)
    guess = Changeset.get_field(changeset, guess_field) |> Enum.join()
    cond do
      String.length(guess) != 5 ->
        {:error, "Guess must be 5 letters"}
      not WordBank.word_exists?(guess) ->
        {:error, "Guess not a valid word"}
      true ->
        {:ok, changeset}
    end
  end

  def five_char_guess?(changeset, guess_row) do
    guess_field = guess_field(guess_row)
    char_count = changeset
    |> Changeset.get_change(guess_field, [])
    |> Enum.count()

    char_count == 5
  end

  def get_char_from_grid(changeset, row, column) do
    guess_field = guess_field(row)
    guess = Changeset.get_field(changeset, guess_field)
    Enum.at(guess, column)
  end

  def update_guesses(changeset, new_character, guess_row) do
    guess_field = guess_field(guess_row)

    current_guess = Changeset.get_change(changeset, guess_field, [])
    updated_guess = current_guess ++ [new_character]
    changeset.changes
    |> Map.merge(%{guess_field => updated_guess})
    |> change_guesses()
  end

  def remove_last_character(changeset, guess_row) do
    guess_field = guess_field(guess_row)
    current_guess = Changeset.get_change(changeset, guess_field, [])
    updated_guess = List.delete_at(current_guess, -1)
    changeset.changes
    |> Map.merge(%{guess_field => updated_guess})
    |> change_guesses()
  end

  defp guess_field(row) do
    String.to_existing_atom("guess_#{row}")
  end

end
