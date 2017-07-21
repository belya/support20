require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, 
    phantomjs: Rails.root.join("bin", "phantomjs").to_s, 
    timeout: 100,
    mode: 'w', 
    charset: 'UTF-8', 
    encoding: 'UTF8'
  )
end

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config| 
  config.before(type: :feature) do 
    WebMock.allow_net_connect!
  end 
 
  config.after(type: :feature) do 
    WebMock.disable_net_connect!
  end 
end