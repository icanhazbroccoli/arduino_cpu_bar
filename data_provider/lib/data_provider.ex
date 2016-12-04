defmodule DataProvider do
  use Application
  require Logger

  def start(_type, _args) do
    status= DataProvider.Supervisor.start_link()
    DataProvider.Timer.register_cb(fn ->
      DataProvider.CPUData.cpu_usage
      |> :erlang.round
      |> Integer.to_string
      |> DataProvider.SerialPort.write
    end)
    status
  end

  defp _inspect(v) do
    Logger.debug inspect(v)
    v
  end

end
