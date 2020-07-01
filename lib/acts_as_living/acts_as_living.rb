
module ActsAsLiving::ActsAsLiving
  def acts_as_living(keys, **options)
    @stage_keys = keys
    @periods = options.dig(:periods)
    @locked_stages = options.dig(:lock_on)
    @death = options.dig(:death)
    @spread = options.dig(:spread)
    @column = options.dig(:column)

    run_definers
  end

  def run_definers
    ActsAsLiving::MethodsDefinder.call(self)
    ActsAsLiving::EnumDefiner.call(self)
    ActsAsLiving::ScopesDefiner.call(self)
    ActsAsLiving::ValidationsDefiner.call(self)
  end
end
