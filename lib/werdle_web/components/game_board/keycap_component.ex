defmodule WerdleWeb.GameBoard.KeycapComponent do
  @moduledoc """
  Live component for rendering a keycap in the keyboard.
  """

  use WerdleWeb, :live_component

  @background_heirarchy %{
    "bg-green-600" => 4,
    "bg-yellow-600" => 3,
    "bg-red-600" => 2,
    "bg-gray-500" => 1
  }

  @impl true
  def update(%{id: id, keycap_value: keycap_value}, socket) do
    socket = socket
    |> assign(:id, id)
    |> assign(:keycap_value, keycap_value)
    |> assign(:background, socket.assigns[:background] || "bg-gray-500")
    {:ok, socket}
  end

  @impl true
  def handle_event("keycap_background", %{"background" => background}, socket) do
    current_priority = Map.get(@background_heirarchy, socket.assigns.background, 0)
    new_priority = Map.get(@background_heirarchy, background, 0)
    new_background = if new_priority > current_priority, do: background, else: socket.assigns.background

    socket = assign(socket, :background, new_background)
    {:noreply, socket}
  end

  @impl true
  def render(%{keycap_value: "backspace"} = assigns) do
    ~H"""
    <kbd id={@id} phx-click="backspace" class="kbd kbd-lg bg-gray-500 text-slate-200 cursor-default rounded-md border-transparent">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"   stroke="currentColor" class="w-10 sm:w-7">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 9.75L14.25 12m0 0l2.25 2.25M14.25 12l2.25-2.25M14.25 12L12 14.25m-2.58 4.92l-6.375-6.375a1.125 1.125 0 010-1.59L9.42 4.83c.211-.211.498-.33.796-.33H19.5a2.25 2.25 0 012.25 2.25v10.5a2.25 2.25 0 01-2.25 2.25h-9.284c-.298 0-.585-.119-.796-.33z" />
      </svg>
    </kbd>
    """
  end

  def render(%{keycap_value: "enter"} = assigns) do
    ~H"""
    <kbd id={@id} phx-click="enter" class="kbd kbd-lg bg-gray-500 text-slate-200 cursor-default font-bold border-transparent rounded-md py-3 text-xs">
      <%= String.upcase(@keycap_value) %>
    </kbd>
    """
  end

  def render(assigns) do
    ~H"""
    <kbd id={@id} phx-click="letter" phx-value-key={@keycap_value} class={"kbd kbd-md sm:kbd-lg #{@background} text-slate-200 cursor-default font-bold font-sans border-transparent rounded-md py-2 sm:py-3 px-0 w-2 sm:px-1"}>
      <%= String.upcase(@keycap_value) %>
    </kbd>
    """
  end
end
