defmodule DataProvider.SerialPort do

  use GenServer
  import Nerves.UART
  require Logger

  @port_baud 9_600
  @timer_retry_hold 2_000
  @modem_type "usbmodem"

  def start_link() do
    GenServer.start_link(__MODULE__, %{pid: nil}, name: __MODULE__)
  end

  defp open_port(pid) do
    port_name= Nerves.UART.enumerate
          |> Map.keys
          |> Enum.find(fn path ->
            case :binary.match(path, @modem_type) do
              :nomatch -> false
              _ -> true
            end
          end)
    case port_name do
      nil ->
        Logger.error "Can not find the modem"
        {:error, "Can not find the modem"}
      _ ->
        Logger.debug "Found modem: #{port_name}"
        Nerves.UART.open(pid, port_name, speed: @port_baud,
                                        active: true,
                            rx_framing_timeout: 5_000)
        {:ok, port_name}
    end
  end


  def init(state) do
    {:ok, pid}= Nerves.UART.start_link
    open_port(pid)
    {:ok, Map.put(state, :pid, pid)}
  end

  def write(data) do
    GenServer.call(__MODULE__, {:write, data})
  end

  def handle_call({:write, data}, _from, state= %{pid: pid}) do
    status= case pid do
      nil ->
        Logger.warn "The modem pid is empty, the data would be dropped on the floor"
        nil
      _ ->
        case Nerves.UART.write(pid, data) do
          :ok -> :ok
          {:error, :ebadf} ->
            # Probably the modem has been disconnected
            :timer.sleep @timer_retry_hold
            open_port(pid)
        end
    end
    Logger.debug inspect(status)
    {:reply, :ok, state}
  end

end
