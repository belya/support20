RSpec.configure do |config|
  config.before do
    ActionController::Base.allow_forgery_protection = true
  end

  config.after do
    ActionController::Base.allow_forgery_protection = false
  end
end