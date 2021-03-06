module Insight

  class RedisPanel < Panel
    require "insight/panels/redis_panel/redis_extension"

    require "insight/panels/redis_panel/stats"

    def self.record(redis_command_args, backtrace, &block)
      return block.call unless Insight.enabled?

      start_time = Time.now
      result = block.call
      total_time = Time.now - start_time
      stats.record_call(total_time * 1_000, redis_command_args, backtrace)
      return result
    end

    def self.reset
      Thread.current["insight.redis"] = Stats.new
    end

    def self.stats
      Thread.current["insight.redis"] ||= Stats.new
    end

    def name
      "redis"
    end

    def heading
      "Redis: %.2fms (#{self.class.stats.queries.size} calls)" % self.class.stats.time
    end

    def content
      result = render_template "panels/redis", :stats => self.class.stats
      self.class.reset
      return result
    end

  end

end
