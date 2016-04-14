defmodule ReportNotifyServer do
  @moduledoc false
  use GenServer

  def notify(data) do
    members = :pg2.get_members :notifications
    for m <- members, do: GenServer.cast m, {:notify, data}
    :ok
  end

  def connect() do
    client = self()
    members = :pg2.get_members :notifications
    for m <- members, do: GenServer.cast m, {:connect, client}
  end

  def start_link() do
    opts = []
    state = %{}
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_opts) do
    :ok = :pg2.create :web_notifications
    :ok = :pg2.create :notifications
    :ok = :pg2.join :notifications, self()
    {:ok, %{}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast({:notify, data}, state) do
    IO.puts "Server received notification: #{inspect data}"
    id = Integer.to_string(data["id"])
    state = Map.put state, id, data
    # tell everyone
    state = case state[id] do
      %{"state" => "COMPLETED"} ->
        Map.delete(state, id)
      %{"state" => "CANCELLED"} ->
        Map.delete(state, id)
      _ ->
        state
    end
    # tell everyone
    members = :pg2.get_members :web_notifications
    {:ok, msg} = Poison.encode %{type: :update, data: data}, [:pretty]
    for m <- members, do: send m, {:msg, msg}
    {:noreply, state}
  end

  def handle_cast({:connect, client}, state) do
    {:ok, msg} = Poison.encode %{type: :state, data: state}, [:pretty]
    send client, {:msg, msg}
    {:noreply, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end