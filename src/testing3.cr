require "kemal"
require "webview"

# Settings
IP     = "127.0.0.1"
PORT   = 3000
WIDTH  =  800
HEIGHT =  800
ROOT   = "root"

# State
class State
  property counter : Int64
  @mutex = Mutex.new

  def initialize(counter : Int64 = 0)
    @counter = counter
  end

  def increment
    @mutex.synchronize do
      @counter += 1
    end
  end
end

state = State.new

# Server
spawn do
  Kemal.config.port = (ENV["PORT"]? || PORT).to_i
  Kemal.config.host_binding = ENV["HOST_BINDING"]? || "#{IP}"
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
      <div> Counter: #{state.counter} </div>
    </div>
    HTML
  end

  # Increment
  post "/increment" do |env|
    state.increment
    <<-HTML
      <div> Counter: #{state.increment} </div>
    HTML
  end

  Kemal.run
end

# Run app
run_app("Testing...")

# Webview
def run_app(title : String)
  puts "http://#{IP}:#{PORT}/#{ROOT}"

  wv = Webview.window(WIDTH, HEIGHT, Webview::SizeHints::NONE,
    "#{title}",
    "http://#{IP}:#{PORT}/#{ROOT}")

  wv.run
  wv.destroy
end
