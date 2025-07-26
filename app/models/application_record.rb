# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  
  # Global scopes and methods available to all models
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(active: true) }
  
  # Audit trail helper for tracking changes
  def audit_changes
    return unless changed?
    
    Rails.logger.info "#{self.class.name} #{id} changed: #{changes.inspect}"
  end
end