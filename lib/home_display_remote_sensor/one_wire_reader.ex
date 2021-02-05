defmodule HomeDisplayRemoteSensor.OneWireReader do
  use GenServer
  require Logger

  @wait_between 3_600_000
  @base_url Application.get_env(:home_display_remote_sensor, :home_display_base_url)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :check, 10_000)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:check, state) do
    Process.send_after(self(), :check, @wait_between)

    OneWire.read_sensors()
    |> send_readings()

    {:noreply, state}
  end

  def send_readings(data) do
    Tesla.post("#{@base_url}/temperature", data |> Jason.encode!(), headers: [{"Content-Type", "application/json"}])
  end
end
