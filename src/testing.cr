# file register.cr

require "kemal"
require "webview"

# ============
# Settings
# ============

# App params
IP     = "127.0.0.1"
PORT   = 3000
WIDTH  =  800
HEIGHT =  800
ROOT   = "root"

# ====================
# Server
# ====================

state : Int64 = 0

spawn do #
  Kemal.config.port = (ENV["PORT"]? || PORT).to_i
  Kemal.config.host_binding = ENV["HOST_BINDING"]? || "#{IP}"
  # Kemal.config.env = "production"
  Kemal.config.env = "development"

  # Root
  get "/#{ROOT}" do
    Log.info { "State: #{state}" }

    <<-HTML
    
    <script src="https://unpkg.com/htmx.org@1.9.6"></script>
    <script src="https://unpkg.com/htmx.org/dist/ext/debug.js"></script>

    <input type="text" value="testing....">

    <div>
      <h1> HTMX tests </h1>
    </div>

    <div> 
      <button hx-post="/increment" hx-target="#counter">
        increment
      </button>
    </div>
    
    <div id="counter"> Counter: #{state} </div>
    HTML
  end

  # Increment
  post "/increment" do
    state = state + 1
    Log.info { "State -> #{state}" }
    <<-HTML
      <div id="counter"> Counter (modified): #{state} </div>
    HTML
  end

  # Run server
  Kemal.run
end # spawn

# Run app
run_app("Testing...")

# ====================
# Webview
# ====================

def run_app(title : String)
  puts "http://#{IP}:#{PORT}/#{ROOT}"

  wv = Webview.window(WIDTH, HEIGHT, Webview::SizeHints::NONE,
    "#{title}",
    "http://#{IP}:#{PORT}/#{ROOT}")

  wv.run
  wv.destroy
end
