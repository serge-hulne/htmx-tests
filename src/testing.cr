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
# State
# ====================

class State
  property counter : Int64
  def initialize(counter : Int64 = 0)
    @counter = counter
  end
end

# ================
# Store
# ================


def setState (state : State) 
  mut = Mutex.new
  mut.lock
  state.counter += 1
  mut.unlock
end

def getState (oldState : State)
  mut = Mutex.new
  mut.lock
  newState = State.new(oldState.counter)
  mut.unlock
  return newState
end


# ====================
# Server
# ====================

state = State.new

spawn do #
  Kemal.config.port = (ENV["PORT"]? || PORT).to_i
  Kemal.config.host_binding = ENV["HOST_BINDING"]? || "#{IP}"
  # Kemal.config.env = "production"
  Kemal.config.env = "development"

  # Root
  get "/#{ROOT}" do
    <<-HTML
    <script src="https://unpkg.com/htmx.org@1.9.6"></script>
    <script src="https://unpkg.com/htmx.org/dist/ext/debug.js"></script>

    <input type="text" value="testing....">

    <div>
      <h1> HTMX tests </h1>
    </div>
    
    <form>
        <br>
        <button hx-post="/increment" hx-target="#cpt" hx-ext="debug">
            increment counter
        </button>
    </form>
    <br>
    <div id="cpt"> 
      <div> Counter: 0 </div>
    </div>
    HTML
  end

  # Increment
  post "/increment" do |env|
    Log.info { "State -> #{state.counter}" }
    setState(state)
    <<-HTML
      <div> Counter: #{getState(state).counter} </div>
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
