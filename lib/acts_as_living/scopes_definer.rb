module ActsAsLiving::ScopesDefiner
  def self.call(klass)
    klass.class_eval do
      stages.each do |stage, _num|
        scope "past_#{stage}", -> { where('stage >= ?', stages[stage]) }
        scope "pre_#{stage}", -> { where('stage < ?', stages[stage]) }
        scope "not_#{stage}", -> { where.not(stage: stage) }
      end

      scope :cancelled, -> { where('stage < 0') }

      @periods.each do |period, delimiters|
        if delimiters.length == 1
          scope period, -> { where(stage: delimiters.first) }
        else
          scope period, lambda {
            where('stage >= ? AND stage <= ?', stages[delimiters.first], stages[delimiters.second])
          }
        end
      end
    end
  end
end
