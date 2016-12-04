defmodule DataProvider.CPUData do

  def cpu_usage do
    :cpu_sup.util
  end

end
