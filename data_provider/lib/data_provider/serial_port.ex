defmodule DataProvider.SerialPort do

  use GenServer
  import Nerves.UART
  require Logger

  @port_baud 9600
  @modem_type "usbmodem"

  def start_link() do
    GenServer.start_link(__MODULE__, %{pid: nil}, name: __MODULE__)
  end

  def init(state) do
    {:ok, pid}= Nerves.UART.start_link
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
      _ ->
        Logger.debug "Found modem: #{port_name}"
        Nerves.UART.open(pid, port_name, speed: @port_baud, active: true)
    end
    {:ok, Map.put(state, :pid, pid)}
  end

  def write(data) do
    GenServer.call(__MODULE__, {:write, data})
  end

  def handle_call({:write, data}, _from, state= %{pid: pid}) do
    case pid do
      nil ->
        Logger.warn "The modem pid is empty, the data would be dropped on the floor"
      _ -> Nerves.UART.write(pid, data)
    end
    {:reply, :ok, state}
  end

end
