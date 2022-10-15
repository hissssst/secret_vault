defmodule Mix.Tasks.Scr.Edit do
  @moduledoc """
  Creates a new secret in specified environment and under specified
  name.

  It uses configuration of current application to retrieve keys and
  so on.

  ## Usage

      mix scr.edit prod database_url
  """

  @shortdoc "Create a new secret"

  use Mix.Task

  alias SecretVault.{ConfigHelper, EditorHelper}

  @default_editor "nano"

  @impl true
  def run(args)

  def run([environment, name | rest]) do
    key = ""

    editor =
      case System.get_env("EDITOR") do
        nil -> @default_editor
        "" -> @default_editor
        value -> value
      end

    otp_app = Mix.Project.config()[:app]
    prefix = find_prefix(rest)

    with {:ok, config} <- ConfigHelper.fetch_config(otp_app, prefix),
         {:ok, original_data} <-
           SecretVault.fetch_secret(config, key, environment, name),
         {:ok, updated_data} <-
           EditorHelper.open_file_on_edit(editor, original_data) do
      SecretVault.put_secret(config, key, environment, name, updated_data)
    else
      {:error, {:no_configuration_for_prefix, prefix}} ->
        Mix.shell().error("No configuration for prefix #{prefix} found")

      {:error, :no_vaults_configured} ->
        Mix.shell().error("No vaults configured for the app")

      {:error, :no_prefix_provided_when_multiple_configured} ->
        message =
          "No prefix provided when multiple configured. " <>
            "Use --prefix option to specify the prefix"

        Mix.shell().error(message)

      {:error, {:non_zero_exit_code, code, message}} ->
        Mix.shell().error("Non zero exit code #{code}: #{message}")

      {:error, {:executable_not_found, editor}} ->
        Mix.shell().error("Editor not found: #{editor}")

      {:error, :secret_not_found} ->
        message = "Secret #{name} not found in environment #{environment}"
        Mix.shell().error(message)

      {:error, :unknown_environment} ->
        Mix.shell().error("Environment #{environment} does not exist")
    end
  end

  def run(_args) do
    msg = "Invalid number of arguments. Use `mix help scr.edit`."
    Mix.shell().error(msg)
  end

  defp find_prefix(["--prefix", prefix | _rest]) do
    prefix
  end

  defp find_prefix([_ | rest]) do
    find_prefix(rest)
  end

  defp find_prefix([]) do
    nil
  end
end