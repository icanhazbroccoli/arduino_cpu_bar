defmodule DataProvider.Supervisor do

  import Supervisor.Spec, warn: false

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children= [
      worker(:cpu_sup, []),
      worker(DataProvider.Timer, []),
      worker(DataProvider.SerialPort, []),
    ]
    supervise(children, strategy: :one_for_one)
  end

end
