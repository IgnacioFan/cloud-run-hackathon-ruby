class ActionProcessor
  MY_URL = "https://cloud-run-hackathon-v2-bxlyqop23a-uc.a.run.app".freeze

  attr_accessor :sub_queue, :arena_state, :me

  def initialize(request_params)
    @sub_queue = []
    @arena_state = request_params["arena"]["state"]
    @me = request_params["arena"]["state"][MY_URL]
  end

  def process
    return flee if attackers? && me["wasHit"]
    return "T" if targets?
    ["F", "L", "R"].sample
  end

  private

  def targets
    @_targets ||= begin
      range = case me["direction"]
      when "N"
        north_range(me)
      when "S"
        south_range(me)
      when "W"
        west_range(me)
      when "E"
        east_range(me)
      end
      arena_state.select do |_, target|
        range.include?(target.slice("x", "y").values)
      end
    end
  end

  def targets?
    targets.any?
  end

  def attackers
    @_attackers ||= begin
      location = me.slice("x", "y").values
      arena_state.select do |_, attacker|
        next if attacker == me
        range = case attacker["direction"]
        when "N"
          north_range(attacker)
        when "S"
          south_range(attacker)
        when "W"
          west_range(attacker)
        when "E"
          east_range(attacker)
        end
        range.include?(location)
      end
    end
  end

  def attackers?
    attackers.any?
  end

  def flee
    ["F", "L", "R"].sample
  end

  def north_range(role)
    [
      [role["x"], role["y"] - 1],
      [role["x"], role["y"] - 2],
      [role["x"], role["y"] - 3]
    ]
  end

  def south_range(role)
    [
      [role["x"], role["y"] + 1],
      [role["x"], role["y"] + 2],
      [role["x"], role["y"] + 3]
    ]
  end

  def west_range(role)
    [
      [role["x"] - 1, role["y"]],
      [role["x"] - 2, role["y"]],
      [role["x"] - 3, role["y"]]
    ]
  end

  def east_range(role)
    [
      [role["x"] + 1, role["y"]],
      [role["x"] + 2, role["y"]],
      [role["x"] + 3, role["y"]]
    ]
  end
end
