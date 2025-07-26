# app/jobs/application_job.rb
# Base job class with common functionality
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that fail
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  # Discard jobs with certain exceptions
  discard_on ActiveJob::DeserializationError

  # Logging for job execution
  around_perform :log_job_execution

  private

  def log_job_execution
    start_time = Time.current
    Rails.logger.info "Starting job #{self.class.name} with arguments: #{arguments.inspect}"
    
    yield
    
    duration = Time.current - start_time
    Rails.logger.info "Completed job #{self.class.name} in #{duration.round(2)}s"
  rescue => e
    Rails.logger.error "Job #{self.class.name} failed: #{e.message}"
    raise
  end
end