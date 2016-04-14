defmodule ReportNotifyWebSocketHandler do
    @moduledoc false

    @behaviour :cowboy_websocket_handler

    def init(_transport, req, opts) do
        {:upgrade, :protocol, :cowboy_websocket, req, opts}
    end

    def websocket_init(_transport_name, req, _opts) do
        state = %{}
        :ok = :pg2.create :web_notifications
        :ok = :pg2.join :web_notifications, self()
        ReportNotifyServer.connect
        {:ok, req, state}
    end

    def websocket_handle(data, req, state) do
        {:ok, req, state}
    end

    def websocket_info({:msg, msg}, req, state) do
        {:reply, {:text, msg}, req, state}
    end

    def websocket_info(_info, req, state) do
        {:ok, req, state}
    end

    def websocket_terminate(_reason, _req, _state) do
        :ok
    end

end