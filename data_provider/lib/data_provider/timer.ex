defmodule DataProvider.Timer do

  use GenServer

  @timer_interval 1_500

  def start_link() do
    GenServer.start_link(__MODULE__, %{timer: nil, callbacks: []}, name: __MODULE__)
  end

  def init(state) do
    next_tick
    {:ok, state}
  end

  def register_cb(cb) do
    GenServer.call(__MODULE__, {:register_cb, cb})
  end

  defp next_tick() do
    Process.send_after(self(), :tick, @timer_interval)
  end

  def handle_info(:tick, state= %{ timer: timer, callbacks: callbacks }) do
    case timer do
      nil -> :ok
      _ -> Process.cancel_timer(timer)
    end
    callbacks |> Enum.each(fn cb -> cb.() end)
    next_tick
    {:noreply, Map.put(state, :timer, timer)}
  end

  def handle_call({:register_cb, cb}, _from, state= %{callbacks: callbacks}) do
    {:reply, :ok, Map.put(state, :callbacks, [cb | callbacks])}
  end

end
