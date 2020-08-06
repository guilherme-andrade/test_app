class BaseService
  attr_reader :result, :errors

  def self.call(*args)
    service = new(*args)
    service.call
    service
  end

  def call; end

  def success?
    errors.any?
  end
end
