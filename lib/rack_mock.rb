# Replaces particular requests with a mock in order to do things like
# test javascript failure modes via Cucumber.
class RackMock
  
  def initialize(app)
    @@mocks ||= {}
    @app = app       
  end                
  
  def self.mock(path, status, headers = {}, body = "")
    @@mocks ||= {}
    @@mocks[path] = [status, headers, body]
  end

  def self.reset
    @@mocks = {}
  end

  def call(env)
    @@mocks.each_pair do |path, response|
      if env["PATH_INFO"] =~ /#{path}/
        puts "MOCKING #{path}"
        return response
      end
    end
    puts "NOPE #{env["PATH_INFO"]}"
    @app.call(env)
  end
                  
end  