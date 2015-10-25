class CircuitBreaker
  attr_reader :failure_threshold,
              :failure_count,
              :reset_timeout,
              :last_failed

  def initialize(options)
    @failure_threshold = (options.fetch(:failure_threshold) || (raise 'no failure threshold specified')).to_i
    @reset_timeout = (options.fetch(:reset_timeout) || (raise 'no reset timeout specified')).to_i

    @failure_count = 0
    @last_failed = nil
  end

  def state
    case
    when (failure_count >= failure_threshold) &&
      (Time.now - last_failed) >= reset_timeout
      :half_open
    when (failure_count >= failure_threshold)
      :open
    else
      :closed
    end
  end

  def fail_immediately?
    state == :open
  end

  def operate
    yield
    reset
  rescue
    record_failure
  end

  private

  def record_failure
    @failure_count += 1
    @last_failed = Time.now
  end

  def reset
    @failure_count = 0
    @last_failed = nil
  end
end
