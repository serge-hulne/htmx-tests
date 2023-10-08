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
    # Log.info { "State: #{state.counter}" }
    <<-HTML

    <title> Testing </title>

      <input type="text" value="testing....">

      <div>
        <h1> HTMX tests </h1>
      </div>
      
      <form>
          <br>
          <button data-hx-post="/increment" data-hx-target="#cpt">
              increment counter
          </button>
      </form>
      <br>
      <div id="cpt"> 
        <div> Counter: 0 </div>
      </div>

        <script>
          document.addEventListener('click', function(event) {
            let target = event.target;
            
            // Check if element has the data-hx-post attribute
            if (target.getAttribute('data-hx-post')) {
                event.preventDefault();
                
                // Make the AJAX POST request
                fetch(target.getAttribute('data-hx-post'), {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: new URLSearchParams(new FormData(target.closest('form')))
                })
                .then(response => response.text())
                .then(html => {
                    let targetElement = document.querySelector(target.getAttribute('data-hx-target'));
                    if (targetElement) {  
                        targetElement.innerHTML = html;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            }
        });
        </script>
    HTML
  end

  # Increment
  post "/increment" do |env|
    Log.info { "State -> #{state.counter}" }
    state.counter = state.counter + 1
    <<-HTML
      <div> Counter (modified): #{state.counter} </div>
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
