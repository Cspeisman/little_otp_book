defmodule Metex do
  def temperatures_of(cities) do
    coordinator_pid = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

    cities |> Enum.each(fn city ->
      worker_pid = spawn(Metex.Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end)
  end
end

defmodule Ping do
  def start do
    {:ok, ping_pid} = Task.start_link(fn -> loop() end)
    {:ok, pong_pid} = Pong.start()
    send(pong_pid, {:ok, :pong, ping_pid})
  end

  def loop do
    receive do
      {:ok, :ping, sender} ->
        IO.puts("ping!")
        Process.sleep(1000)
        send(sender, {:ok, :pong, self()})
    end

    loop()
  end
end

defmodule Pong do
  def start do
    Task.start_link(fn -> loop() end)
  end
  def loop do
    receive do
      {:ok, :pong, sender} ->
        IO.puts("pong!")
        Process.sleep(1000)
        send(sender, {:ok, :ping, self()})
    end
    loop()
  end
end
