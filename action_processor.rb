class ActionProcessor
  @@acton = "attack"
  @@attack_quota = 4

  MY_URL = "https://cloud-run-hackathon-v2-bxlyqop23a-uc.a.run.app".freeze

  TURN_LEFT_DIRECTION = {
    "N" => "W",
    "S" => "E",
    "W" => "S",
    "E" => "N"
  }

  attr_accessor :sub_queue, :arena_state, :me

  def initialize(request_params)
    @sub_queue = []
    @arena_state = request_params["arena"]["state"]
    @me = request_params["arena"]["state"][MY_URL]
  end

  def process
    count_attacked_quota

    case @@acton
    when "attack"
      return "T" if targets?

      if turn_left?
        "L"
      else
        "R"
      end
    when "flee"
      case @@attack_quota
      when 0
        @@attack_quota = 4
        @@acton = "attack"
        "F"
      when 1
        @@attack_quota = 0
        turn_left? ? "L" : "R"
      when 2
        @@attack_quota -= 1
        "F"
      when 3
        @@attack_quota -= 1
        turn_left? ? "L" : "R"
      end
    end
  end

  private

  def count_attacked_quota
    if me["wasHit"] && @@attack_quota == 4
      @@acton = "flee"
      @@attack_quota -= 1
    end
  end

  def turn_left?
    range = case TURN_LEFT_DIRECTION[me["direction"]]
    when "N"
      north_range(me)
    when "S"
      south_range(me)
    when "W"
      west_range(me)
    when "E"
      east_range(me)
    end
    arena_state.any? do |_, target|
      !range.include?(target.slice("x", "y").values)
    end
  end

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

  # def attackers_against_me
  #   @_attackers_against_me ||= attackers.select do |_, attacker|
  #     attacker["direction"]
  #     case attacker["direction"]
  #     when "N"
  #       me["direction"] == "S"
  #     when "S"
  #       me["direction"] == "N"
  #     when "W"
  #       me["direction"] == "E"
  #     when "E"
  #       me["direction"] == "W"
  #     end
  #   end
  # end

  # def flee
  #   if flee_forward?
  #     "F"
  #   else
  #     ["R", "L"].sample
  #   end
  # end

  # def flee_forward?
  #   attackers_against_me.any? do |_, attacker|
  #     count = case attacker["dimension"]
  #     when "N"
  #       attacker["y"] - me["y"]
  #     when "S"
  #       me["y"] - attacker["y"]
  #     when "W"
  #       attacker["x"] - me["x"]
  #     when "E"
  #       me["x"] - attacker["x"]
  #     end
  #     count > 0
  #   end
  # end

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
