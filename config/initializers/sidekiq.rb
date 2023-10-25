Sidekiq.configure_server do |config|
  logger = ActiveSupport::Logger.new("log/sidekiq_#{Rails.env}.log")
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  config.redis = { url: ENV["REDIS_URL"] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end
