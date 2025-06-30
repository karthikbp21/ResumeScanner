class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "✅ Sidekiq test job ran successfully!"
  end
end
