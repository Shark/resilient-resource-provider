class CircuitBreaker
  attr_reader :failure_threshold,
              :failure_count,
              :reset_timeout,
              :last_failed

  def initialize(options)
    @failure_threshold = (options.fetch(:failure_threshold) || (raise 'no failure threshold specified')).to_i
    @reset_timeout = (options.fetch(:reset_timeout) || (raise 'no reset timeout specified')).to_i

    update
  end

  def state
    update

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

  def update
    @failure_count = Diplomat::Kv.get('calculator_provider/circuit_breaker/failure_count').to_i

    last_failed_from_consul = Diplomat::Kv.get('calculator_provider/circuit_breaker/last_failed')
    if last_failed_from_consul && last_failed_from_consul.length > 0
      @last_failed = Time.iso8601(last_failed_from_consul)
    else
      @last_failed = nil
    end
  end

  private

  def record_failure
    update
    @failure_count += 1
    @last_failed = Time.now
    push
  end

  def reset
    @failure_count = 0
    @last_failed = nil
    push
  end

  def push
    Diplomat::Kv.put('calculator_provider/circuit_breaker/failure_count', failure_count.to_s)
    Diplomat::Kv.put('calculator_provider/circuit_breaker/last_failed', (last_failed.nil? ? '' : last_failed.iso8601))
  end
end
