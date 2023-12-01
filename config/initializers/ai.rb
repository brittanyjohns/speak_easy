puts "Setting up AI"
ENV["AI_ENABLED"] = Rails.env.production? ? "false" : "true"
puts "AI_ENABLED: #{ENV["AI_ENABLED"]}"
