# app/services/application_service.rb
# Base service class following Rails service object pattern
class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  def initialize(*args)
    # Override in subclasses
  end

  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  private

  def success(result = {})
    ServiceResult.new(success: true, data: result)
  end

  def failure(error_message, errors = {})
    ServiceResult.new(
      success: false, 
      error: error_message, 
      errors: errors
    )
  end
end

# Service result object for consistent return values
class ServiceResult
  attr_reader :data, :error, :errors

  def initialize(success:, data: {}, error: nil, errors: {})
    @success = success
    @data = data
    @error = error
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !success?
  end
end