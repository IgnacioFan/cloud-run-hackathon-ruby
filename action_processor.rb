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

  OPPOSITE_DIRECTION = {
    "N" => "S",
    "S" => "N",
    "W" => "E",
    "E" => "W"
  }

  attr_accessor :sub_queue, :arena_state, :me, :max_width, :max_height

  def initialize(request_params)
    @sub_queue = []
    @arena_state = request_params["arena"]["state"]
    @me = request_params["arena"]["state"][MY_URL]
    @max_width = request_params["arena"]["dims"][0]
    @max_height = request_params["arena"]["dims"][1]
  end

  def process
    count_attacked_quota
    case @@acton
    when "attack" then attack!
    when "flee" then flee!
    end
  end

  private

  def attack!
    if target?
      "T"
    elsif closing_border?
      turn_left? ? "L" : "R"
    else
      ["L", "R", "F"].sample
    end
  end

  def count_attacked_quota
    if me["wasHit"] && @@attack_quota == 4
      @@acton = "flee"
      @@attack_quota -= 1
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

  def target?
    !targets.empty?
  end

  def closing_border?
    case me["direction"]
    when "N"
      [0, 1].include?(me["y"])
    when "S"
      [max_height, max_height - 1].include?(me["y"])
    when "W"
      [0, 1].include?(me["x"])
    when "E"
      [max_width, max_width - 1].include?(me["x"])
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

  def flee!
    case @@attack_quota
    when 0
      @@attack_quota = 4
      @@acton = "attack"
      "F"
    when 1
      @@attack_quota = 0
      ["L", "R"].sample
    when 2
      @@attack_quota -= 1
      "F"
    when 3
      @@attack_quota -= 1
      ["L", "R"].sample
    end
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
