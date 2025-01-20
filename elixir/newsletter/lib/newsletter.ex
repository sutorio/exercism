defmodule Newsletter do
  @spec read_emails(String.t()) :: [String.t()]
  def read_emails(path) do
    with {:ok, data} <- File.read(path) do
      data
      |> String.split("\n")
      |> Enum.filter(fn entry -> String.length(entry) > 0 end)
    else
      {:error, reason} -> raise "Could not read emails from #{path}: #{reason}"
    end
  end

  @spec open_log(String.t()) :: pid()
  def open_log(path) do
    case File.open(path, [:write, :utf8]) do
      {:ok, pid} -> pid
      {:error, reason} -> raise "Could not open log file #{path}: #{reason}"
    end
  end

  @spec log_sent_email(pid(), String.t()) :: :ok
  def log_sent_email(pid, email) do
    IO.binwrite(pid, email <> "\n")
  end

  @spec close_log(pid()) :: :ok
  def close_log(pid) do
    File.close(pid)
  end

  @spec send_newsletter(String.t(), String.t(), (String.t() -> :ok)) :: :ok
  def send_newsletter(emails_path, log_path, send_fun) do
    log = open_log(log_path)

    Enum.each(read_emails(emails_path), fn email ->
      if send_fun.(email) == :ok do
        log_sent_email(log, email)
      end
    end)

    close_log(log)
  end
end
