
module ActsAsLiving::ClassMethods
  # validates :status, presence: true

  def acts_as_living(keys, **options)
    @status_keys = keys
    @life_stages = options.dig(:life_stages)
    @locked_statuses = options.dig(:lock_on)
    @death = options.dig(:death)
    @spread = options.dig(:spread)
    @column = options.dig(:column)

    ActsAsLiving::EnumDefiner.call(self)

    run_definers
  end

  def run_definers
    ActsAsLiving::ScopesDefiner.call(self)
    ActsAsLiving::InstanceMethodsDefiner.call(self)
    # ActsAsLiving::CallbacksDefiner.call(self)
    ActsAsLiving::ValidationsDefiner.call(self)
  end

  def alive_statuses
    statuses.except(@death).keys
  end

  def status_keys
    statuses.keys
  end

  def statuses_after(status)
    return [] if final_status?(status)

    statuses[status_after(status)..]
  end

  def statuses_before(status)
    return [] if initial_status?(status)

    index = status_keys.find_index(status)
    status_keys[0...index]
  end

  def status_after(status)
    return if final_status?(status)

    index = status_keys.find_index(status)
    status_keys[index + 1]
  end

  def status_before(status)
    return if initial_status?(status)

    index = status_keys.find_index(status)
    status_keys[index - 1]
  end

  def final_status
    status_keys.last
  end

  def final_status?(status)
    final_status == status
  end

  def initial_status
    statuses.key(0)
  end

  def dead_status
    @death
  end

  def initial_status?(status)
    initial_status == status
  end

  def stages_with_ranges
    @life_stages.map(&method(:to_stage_with_range)).to_h
  end

  def to_stage_with_range(stage, delimiter)
    [stage, (statuses[delimiter.first]..statuses[delimiter.last])]
  end

  def life_stages
    @life_stages
  end

  def life_stages_for(status)
    stages_with_ranges.keys.select do |stage|
      stages_with_ranges[stage].include? statuses[status]
    end
  end
end
