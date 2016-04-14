defmodule ReportNotifyPostHandler do
    @moduledoc false

    def init(_transport, _req, []) do
        {:upgrade, :protocol, :cowboy_rest}
    end

    def allowed_methods(req, state) do
        {["POST"], req, state}
    end

    def content_types_accepted(req, state) do
        {[
            {{"application", "json", []}, :handle_notify}
        ], req, state}
    end

    def handle_notify(req, state) do
        {:ok, body, req} = :cowboy_req.body(req)
        {:ok, data} = Poison.decode body, []
        ReportNotifyServer.notify data
        {true, req, state}
    end
end