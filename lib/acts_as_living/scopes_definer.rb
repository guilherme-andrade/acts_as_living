module ActsAsLiving::ScopesDefiner
  def self.call(klass)
    klass.class_eval do
      statuses.each do |status, _num|
        scope "past_#{status}", -> { where('status >= ?', statuses[status]) }
        scope "pre_#{status}", -> { where('status < ?', statuses[status]) }
        scope "not_#{status}", -> { where.not(status: status) }
      end

      scope :cancelled, -> { where('status < 0') }

      @life_stages.each do |stage, delimiters|
        if delimiters.length == 1
          scope stage, -> { where(status: delimiters.first) }
        else
          scope stage, lambda {
            where('status >= ? AND status <= ?', statuses[delimiters.first], statuses[delimiters.second])
          }
        end
      end
    end
  end
end
