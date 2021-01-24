defmodule AHT20.SensorWorker do
  @moduledoc """
  Wraps a sensor holding a connection.
  """

  use GenServer

  require Logger

  @spec start_link(AHT20.Sensor.config()) :: {:ok, pid} | {:error, any}
  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def read_data(pid), do: GenServer.call(pid, :read_data)

  def read_state(pid), do: GenServer.call(pid, :read_state)

  @impl GenServer
  def init(config) do
    Logger.info("Starting #{__MODULE__} #{inspect(config)}")
    {:ok, _sensor} = AHT20.Sensor.start(config)
  end

  @impl GenServer
  def handle_call(:read_data, _from, sensor) do
    case AHT20.Sensor.read_data(sensor) do
      {:ok, sensor_output} ->
        {:reply, {:ok, AHT20.Measurement.from_sensor_output(sensor_output)}, sensor}

      {:error, reason} ->
        {:reply, {:error, reason}, sensor}
    end
  end

  @impl GenServer
  def handle_call(:read_state, _from, sensor) do
    case AHT20.Sensor.read_state(sensor) do
      {:ok, <<sensor_state_byte>>} ->
        {:reply, {:ok, AHT20.State.from_byte(sensor_state_byte)}, sensor}

      {:error, reason} ->
        {:reply, {:error, reason}, sensor}
    end
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.error("Stopping #{__MODULE__}, reason: #{inspect(reason)}")
  end
end