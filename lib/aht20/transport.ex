defmodule AHT20.Transport do
  @moduledoc """
  The communication bus between the target board and the AHT20 sensor.
  """

  @type bus_name :: String.t()
  @type bus_address :: 0..127
  @type transport :: pid
  @type register :: non_neg_integer()

  @callback start_link(bus_name: bus_name, bus_address: bus_address) ::
              {:ok, transport} | {:error, any}

  @callback read(transport, integer) ::
              {:ok, binary} | {:error, any}

  @callback write(transport, iodata) ::
              :ok | {:error, any}

  @callback write(transport, register, iodata) ::
              :ok | {:error, any}

  @callback write_read(transport, register, integer) ::
              {:ok, binary} | {:error, any}
end
