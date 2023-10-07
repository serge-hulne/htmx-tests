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


spawn do #
  Kemal.config.port = (ENV["PORT"]? || PORT).to_i
  Kemal.config.host_binding = ENV["HOST_BINDING"]? || "#{IP}"
  # Kemal.config.env = "production"
  Kemal.config.env = "development"

  # Root
  get "/#{ROOT}" do

    counter = 10

    # Log.info { "State: #{counter}" }
    <<-HTML
    <input type="text" value="testing....">

    <div>
      <h1> HTMX tests </h1>
    </div>
    
    <form>
        <br>
        <button onclick="post(#{counter})">
            increment counter
        </button>
    </form>
    <br>
    <div id="cpt"> 
      <div> Counter: 0 </div>
    </div>

    <script>
        function post(value) {
            fetch("/increment", {
            method: "POST",
            body: JSON.stringify({
                'counter' : value
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
            })
            .then((response) => response.json())
            .then((json) => console.log(json))
            .catch((error) => console.log(error));
        }
    </script>   
    HTML
  end

  # Increment
  post "/increment" do |env|
    # env.response.content_type = "application/json"
    counter = env.params.json["counter"].as(Int64)
    Log.info { "Response: #{counter}" }
    counter = counter + 1
    {"counter" => "#{counter}"}.to_json
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
