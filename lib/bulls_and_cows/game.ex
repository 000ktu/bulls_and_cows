defmodule BullsAndCows.Game do
  @moduledoc """
  Игровой модуль для игры "Быки и Коровы".
  """

  @guess_length 4

  def start_game do
    secret_number = generate_secret_number()
    %{secret: secret_number, guesses: %{}, status: :playing}
  end

  def make_guess(game_state, guess) do
    case validate_guess(guess) do
      :error ->
        {:error, "Некорректный ввод. Попробуйте еще раз."}
      {:ok, guess} ->
        {bulls, cows} = calculate_bulls_and_cows(game_state.secret, guess)
        updated_guesses = Map.put(game_state.guesses, guess, %{bulls: bulls, cows: cows})

        if bulls == @guess_length do
          {:ok, %{game_state | guesses: updated_guesses, status: :won}}
        else
          {:ok, %{game_state | guesses: updated_guesses}}
        end
    end
  end

  defp validate_guess(guess) when is_binary(guess) do
    if String.length(guess) == @guess_length and String.match?(guess, ~r/^\d+$/) do
      {:ok, guess}
    else
      :error
    end
  end

  defp validate_guess(_), do: :error

  defp generate_secret_number do
    Enum.take_random(0..9, @guess_length)
    |> Enum.join()
  end

  defp calculate_bulls_and_cows(secret_number, guess) do
    secret_digits = String.graphemes(secret_number)
    guess_digits = String.graphemes(guess)

    bulls = Enum.zip(secret_digits, guess_digits)
             |> Enum.count(fn {s, g} -> s == g end)

    secret_remaining = Enum.filter(Enum.zip(secret_digits, guess_digits), fn {s, g} -> s != g end)
                          |> Enum.map(fn {s, _} -> s end)
    guess_remaining = Enum.filter(Enum.zip(secret_digits, guess_digits), fn {s, g} -> s != g end)
                          |> Enum.map(fn {_, g} -> g end)

    cows = Enum.reduce(guess_remaining, 0, fn g, acc ->
      if g in secret_remaining do
        secret_remaining = List.delete(secret_remaining, g)
        acc + 1
      else
        acc
      end
    end)

    {bulls, cows}
  end
end
