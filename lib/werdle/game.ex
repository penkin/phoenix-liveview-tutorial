defmodule Werdle.Game do
  @moduledoc """
  A module for managing the game state and logic.
  """

  alias Werdle.Game.Guesses

  def change_guesses(guesses) do
    Guesses.changeset(guesses)
  end
end
