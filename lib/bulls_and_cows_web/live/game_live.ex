defmodule BullsAndCowsWeb.GameLive do
  use BullsAndCowsWeb, :live_view

  alias BullsAndCows.Game

  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Game.start_game(), guess: "", feedback: nil)}
  end

  def handle_event("make_guess", %{"guess" => guess}, socket) do
    game = socket.assigns.game

    case Game.make_guess(game, guess) do
      {:ok, updated_game} ->
        feedback = updated_game.guesses[guess]
        {:noreply, assign(socket, game: updated_game, feedback: feedback, guess: "")}

      {:error, error_msg} ->
        {:noreply, assign(socket, feedback: error_msg)}
    end
  end

  def handle_event("restart_game", _params, socket) do
    {:noreply, assign(socket, game: Game.start_game(), feedback: nil, guess: "")}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Игра "Быки и Коровы"</h1>
      <p>Угадайте 4-значное число</p>

      <form phx-submit="make_guess">
        <input type="text" name="guess" value={@guess} maxlength="4" />
        <button type="submit">Отправить</button>
      </form>

      <div>
        <h2>Результат:</h2>
        <p><%= @feedback && "Быки: #{@feedback.bulls}, Коровы: #{@feedback.cows}" %></p>
        <p><%= @feedback && @game.status == :won && "Поздравляем! Вы угадали число!" %></p>
      </div>

      <div>
        <h2>Предыдущие догадки:</h2>
        <ul>
          <%= for {guess, feedback} <- Enum.reverse(@game.guesses) do %>
            <li><%= guess %>: Быки - <%= feedback.bulls %>, Коровы - <%= feedback.cows %></li>
          <% end %>
        </ul>
      </div>

      <%= if @game.status == :won do %>
        <button phx-click="restart_game">Начать заново</button>
      <% end %>
    </div>
    """
  end
end
