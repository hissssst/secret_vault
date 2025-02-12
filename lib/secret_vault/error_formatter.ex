defmodule SecretVault.ErrorFormatter do
  @moduledoc false
  # Manages rendering errors in CLI

  @spec format(any()) :: String.t()
  def format(message) do
    case message do
      {:unknown_prefix, prefix, environment} ->
        "Prefix #{inspect(prefix)} for environment #{inspect(environment)}" <>
          " does not exist"

      {:secret_already_exists, name} ->
        "Secret with name #{name} already exists"

      {:secret_not_found, name, environment} ->
        "Secret #{name} not found in environment #{inspect(environment)}"

      {:no_configuration_for_prefix, prefix} ->
        "No configuration for prefix #{inspect(prefix)} found"

      {:no_configuration_for_app, otp_app} ->
        "No configuration for otp_app #{otp_app} found"

      {:non_zero_exit_code, code} ->
        "Editor exited with code #{code}"

      {:executable_not_found, editor} ->
        "Editor not found: #{editor}"

      :invalid_encryption_key ->
        "Invalid key. It seems the secret was encrypted with " <>
          "a different encryption key"
    end
  end
end
