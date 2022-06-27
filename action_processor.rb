class ActionProcessor
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
    case $acton
    when "attack" then attack!
    when "running" then running!
    end
  end

  private

  def attack!
    if target?
      "T"
    elsif closing_border?
      ["L", "R"].sample
    else
      ["L", "R", "F"].sample
    end
  end

  def count_attacked_quota
    me["wasHit"] ? $attack_count += 1 : $attack_count = 0
    $acton = "running" if $attack_count >= 3
  end

  def target?
    arena_state.find do |_, target|
      if ["N", "S"].include?(me["direction"])
        me["x"] == target["x"] && axis_y(me["direction"]).include?(target["y"])
      else
        me["y"] == target["y"] && axis_x(me["direction"]).include?(target["x"])
      end
    end
  end

  def axis_x
    @_axis_x ||= if me["direction"] == "W"
      [me["x"] - 1, me["x"] - 2, me["x"] - 3]
    else
      [me["x"] + 1, me["x"] + 2, me["x"] + 3]
    end
  end

  def axis_y
    @_axis_y ||= if me["direction"] == "N"
      [me["y"] - 1, me["y"] - 2, me["y"] - 3]
    else
      [me["y"] + 1, me["y"] + 2, me["y"] + 3]
    end
  end

  def closing_border?
    if me["direction"] == "N"
      [0, 1].include?(me["y"])
    elsif me["direction"] == "S"
      [max_height - 1, max_height].include?(me["y"])
    elsif me["direction"] == "W"
      [0, 1].include?(me["x"])
    else
      [max_width - 1, max_width].include?(me["x"])
    end
  end

  def running!
    case $running_count
    when 0
      $running_count = 3
      "F"
    when 1
      $running_count = 0
      $acton = "attack"
      ["L", "R"].sample
    when 2
      $running_count -= 1
      "F"
    when 3
      $running_count -= 1
      ["L", "R"].sample
    end
  end
end
