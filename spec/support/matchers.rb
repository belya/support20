RSpec::Matchers.define :match_all do |matchers|
  match do |object|
    matchers.all? do |matcher|
      matcher.matches? object
    end
  end

  def supports_block_expectations?
    true
  end
end