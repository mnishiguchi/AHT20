defmodule AHT20 do
  @moduledoc """
  Read temperature and humidity from AHT20 sensor in Elixir.
  """

  use GenServer

  require Logger

  @default_bus_name "i2c-1"
  @default_bus_address 0x38

  @type bus_name :: binary
  @type bus_address :: 0..127

  @typedoc """
  AHT20 GenServer start_link options
  * `:name` - a name for the GenServer
  * `:bus_name` - which I2C bus to use (defaults to `"i2c-1"`)
  * `:bus_address` - the address of the AHT20 (defaults to 0x38)
  """
  @type options() :: [
          name: GenServer.name(),
          bus_name: bus_name,
          bus_address: bus_address
        ]

  @doc """
  Start a new GenServer for interacting with a AHT20.
  Normally, you'll want to pass the `:bus_name` option to specify the I2C
  bus going to the AHT20.
  """
  @spec start_link(options()) :: GenServer.on_start()
  def start_link(init_arg \\ []) do
    GenServer.start_link(__MODULE__, init_arg, name: init_arg[:name])
  end

  def measure(server), do: GenServer.call(server, :measure)

  @impl GenServer
  def init(config) do
    bus_name = config[:bus_name] || @default_bus_name
    bus_address = config[:bus_address] || @default_bus_address

    Logger.info("[AHT20] Starting on bus #{bus_name} at address #{inspect(bus_address, base: :hex)}")

    with {:ok, transport} <- AHT20.Transport.I2C.start_link(bus_name: bus_name, bus_address: bus_address),
         :ok <- AHT20.Sensor.init(transport) do
      {:ok, %{transport: transport}, {:continue, :init_sensor}}
    else
      _error ->
        {:stop, :device_not_found}
    end
  end

  @impl GenServer
  def handle_continue(:init_sensor, state) do
    Logger.info("[AHT20] Initializing sensor")
    :ok = AHT20.Sensor.init(state.transport)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:measure, _from, state) do
    result = AHT20.Sensor.measure(state.transport)
    {:reply, result, state}
  end
end
