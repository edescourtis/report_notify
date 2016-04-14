defmodule ReportNotify do
  @moduledoc false
  
  use Application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile [
        {
            :_, [
                {'/',          :cowboy_static,               {:priv_file, :report_notify, 'static/index.html'}},
                {'/report',    ReportNotifyPostHandler,      []                                               },
                {'/websocket', ReportNotifyWebSocketHandler, []                                               },
                {'/[...]',     :cowboy_static,               {:priv_dir,  :report_notify, 'static'           }}
            ]
        }
    ]

    {:ok, _} = :cowboy.start_http :http_listener, 100, [port: 8666], [env: [dispatch: dispatch]]
    ReportNotify.Supervisor.start_link()
  end
end

defmodule ReportNotify.Supervisor do
  @moduledoc false

  use Supervisor
  import Supervisor.Spec

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    children = [
      worker(ReportNotifyServer, [], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)
  end
end