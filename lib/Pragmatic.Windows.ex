defmodule Pragmatic.Windows do

  use Rustler, otp_app: :pragmatic, crate: :pragmatic

  def add(_arg1, _arg2), do: exit(:nif_not_loaded)
  def check_short_names(_arg1, _arg2), do: exit(:nif_not_loaded)
  @stderr 2
  @stdout 1
  @moduledoc ~S"""
  Utility functions for dealing with issues which arise when using Elixir on Windows.
  """

  @doc ~S"""
  Take a long Windows path or a path with spaces in it and return the 8.3 version of that name

  A runtime error will also be thrown if you attempt to run this function on a non-Windows OS. Also, the function will throw a runtime error if you attempt to invoke it on a path that doesn't exist. Otherwise, you should specify the directory in the format drive:/dir/dir/dir etc. Contrary to the common, mistaken believe forward slashes can be used as a directory separator on Windows.

  ## Examples

      iex> Pragmatic.Windows.get_short_name("c:/nosuchpath")
      ** (RuntimeError) The specified directory "c:/nosuchpath" does not exist

      iex> Pragmatic.Windows.get_short_name("c:/program files")
      "c:/PROGRA~1"

      iex> Pragmatic.Windows.get_short_name("c:/users")
      "c:/Users"

  """
  @spec get_short_name(Path.t)::Path.t
  def get_short_name(path) when is_binary(path) do
    if not(running_on_windows?()), do: raise "This function can only be run on Windows"
    if not(File.exists?(path)), do: raise "The specified directory \"#{path}\" does not exist"
    # If the path contains spaces it needs to be surrouneded with quotes. Otherwise, do _not_ surround it with quotes.
    quoted_path = if path_contains_spaces?(path), do: "\"#{path}\"", else: path

    # NB for some reason I could not get System.cmd to work with this particular shell command.  If you can
    # get it working, please share your fix with me.
    # 2>nul suppresses a bogus error message. 
    :os.cmd('cmd /c FOR %d IN (#{quoted_path}) DO %~sd #{@stderr}>nul') #Pipe stderr to nul so that errors are not displayed.
    |> to_string
    |> strip_newlines_from_string
    |> strip_all_chars_up_to(">")
    |> String.trim
    |> Path.split
    |> Path.join
  end

  @spec path_contains_spaces?(Path.t)::boolean
  defp path_contains_spaces?(path) when is_binary(path) do
    # NB: Currently there's no way I can figure out to tell if the path has a "\" in it (since "\" is an escape character
    # so you must pass the path as /dir/dir/dir (yes this does work on Windows).
    spaces_in_middle = ~r/\S+\s+\S+/
    initial_spaces = ~r/\s+.*/
    trailing_spaces = ~r/.*\s+/
    (String.match?(path,spaces_in_middle) or String.match?(path, initial_spaces) or String.match?(path,trailing_spaces))
  end
  
  @spec strip_newlines_from_string(String.t)::String.t
  defp strip_newlines_from_string(s) when is_binary(s) do
    windows_newline = "\r\n"
    if String.contains?(s,windows_newline), do: String.replace(s, windows_newline, ""), else: s
  end

  @spec get_position_of_char(String.t, String.t , non_neg_integer)::pos_integer
  defp get_position_of_char(s, char, cnt) do
    {g, tail} = String.next_grapheme(s)
    if g === char, do: cnt, else: get_position_of_char(tail, char, cnt+1)
  end

  @spec strip_all_chars_up_to(String.t, String.t)::String.t
  defp strip_all_chars_up_to(s, char) do
    if String.contains?(s,char) do
      index_of_char = get_position_of_char(s, char, 0)
      {_,short_name} = String.split_at(s,index_of_char+1) #Add one since this is 0 based.
      short_name
    end
  end

  @spec running_on_windows?::boolean
  defp running_on_windows?() do
    {osfamily,_} = :os.type()
    osfamily === :win32
  end

  @doc"""
  Is the currently logged-in user an admin?
  """
  @spec user_is_admin?()::boolean
  def user_is_admin?() do
    if not(running_on_windows?()), do: raise "This function can only be run on Windows"
    :os.cmd('cmd /c net session #{@stderr}>&#{@stdout}') # redirect stderr to stdout so error messages can be trapped
    |> to_string
    |> String.contains?("denied")
    |> Kernel.not
  end

  @doc"""
  Return the name of the user the current process is running under.  This is handy for logging errors.  

  ### Parameters
    * show_domain: (boolean)
      * if true, return the current user in the domain\x5Cuser format.  Otherwise, just return user.

  ## Examples

      iex> Pragmatic.Windows.get_current_user(show_domain: false)
      "caten"
 
      iex> Pragmatic.Windows.get_current_user(show_domain: true)
      "DESKTOP-3GQCDMC\\\\caten"

  """
  @spec get_current_user([{:show_domain, boolean}])::String.t
  def get_current_user([show_domain: show_domain]) do
    if not(running_on_windows?()), do: raise "This function can only be run on Windows"
    domain = System.get_env("UserDomain")
    uname = System.get_env("UserName")
    if (show_domain), do: "#{domain}\\#{uname}", else: "#{uname}"
  end
  
end
