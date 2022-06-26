class ActionProcessor
  MY_URL = "https://cloud-run-hackathon-v2-bxlyqop23a-uc.a.run.app".freeze

  attr_accessor :sub_queue, :arena_state, :me, :max_width, :max_height

  def initialize(request_params)
    @sub_queue = []
    @arena_state = request_params["arena"]["state"]
    @me = request_params["arena"]["state"][MY_URL]
  end

  def process
    return flee if attacker? && me["wasHit"]
    return "T" if target?
    ["F", "L", "R"].sample
  end

  private

  def target?
    arena_state.any? do |attacker|
      x, y = attacker["x"], attacker["y"]
      range = case me["direction"]
      when "N"
        [me["y"] - 1, me["y"] - 2, me["y"] - 3]
      when "S"
        [me["y"] + 1, me["y"] + 2, me["y"] + 3]
      when "W"
        [me["x"] - 1, me["x"] - 2, me["x"] - 3]
      when "E"
        [me["x"] + 1, me["x"] + 2, me["x"] + 3]
      end

      if ["N", "S"].include?(me["direction"])
        x == me["x"] && range.include?(y)
      else
        y == me["y"] && range.include?(x)
      end
    end
  end

  def attackers
    @_attackers ||= arena_state.select do |attacker|
      x, y = me["x"], me["y"]
      range = case attacker["direction"]
      when "N"
        [attacker["y"] - 1, attacker["y"] - 2, attacker["y"] - 3]
      when "S"
        [attacker["y"] + 1, attacker["y"] + 2, attacker["y"] + 3]
      when "W"
        [attacker["x"] - 1, attacker["x"] - 2, attacker["x"] - 3]
      when "E"
        [attacker["x"] + 1, attacker["x"] + 2, attacker["x"] + 3]
      end

      if ["N", "S"].include?(attacker["direction"])
        x == attacker["x"] && range.include?(y)
      else
        y == attacker["y"] && range.include?(x)
      end
    end
  end

  def attackers?
    attackers.any?
  end

  def flee
    ["F", "L", "R"].sample
  end
end
