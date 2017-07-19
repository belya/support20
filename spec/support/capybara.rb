require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config| 
  config.before(type: :feature) do 
    WebMock.allow_net_connect!
  end 
 
  config.after(type: :feature) do 
    WebMock.disable_net_connect!
  end 
end