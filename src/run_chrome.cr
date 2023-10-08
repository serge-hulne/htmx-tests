def run_with_chrome(title : String, url : String)
  # Use `google-chrome` for Chrome and `chromium` for Chromium. Adjust as needed.
  browser_command = "google-chrome"

  # Flags:
  # --app=<url>: Opens Chrome in "app" mode—essentially standalone mode without typical browser UI.
  # --window-size=<width>,<height>: Defines the window size.
  command = "#{browser_command} --app=#{url} --window-size=800,800"

  # Execute the command
  system(command)
end

# After setting up your Kemal server:
run_with_chrome("Testing...", "http://#{IP}:#{PORT}/#{ROOT}")
