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

# ================
# Store
# ================

class Store(T)
  property cin, cout : Channel(T)

  def initialize
    @cin = Channel(T).new
    @cout = Channel(T).new
  end

  def run
    spawn do
      while true
        _innerState = @cin.receive
        @cout.send(_innerState)
      end
    end
  end

  def set(value : State)
    @cin.send(value)
  end

  def get : State
    return value = @cout.receive
  end
end

# ====================
# State
# ====================

class State
  property counter : Int64

  def initialize(counter : Int64 = 0)
    @counter = counter
  end
end

# ====================
# Server
# ====================

store = Store(State).new
store.run

spawn do #
  Kemal.config.port = (ENV["PORT"]? || PORT).to_i
  Kemal.config.host_binding = ENV["HOST_BINDING"]? || "#{IP}"
  # Kemal.config.env = "production"
  Kemal.config.env = "development"

  # Root
  get "/#{ROOT}" do
    state = State.new
    store.set(state)
    Log.info { "State: #{state.counter}" }
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
    state = store.get
    Log.info { "State -> #{state.counter}" }
    state.counter += 1
    store.set(state)
    <<-HTML
      <div> Counter: #{state.counter} </div>
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
