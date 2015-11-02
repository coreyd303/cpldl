class Duration

  def self.duration_str(seconds)
    return "0:00" if seconds < 0
    m = (seconds / 60) % 60
    s = (seconds % 60).to_s.rjust(2, "0")
    "#{m}:#{s}"
  end

  def self.minutes_str(seconds)
    return "0 mins" if seconds < 0
    m = (seconds / 60) % 60
    return "1 min" if m == 1
    "#{m} mins"
  end

  def self.duration_str_to_int(str)
    digits_array = str.split(":").map(&:to_i)
    total = digits_array.first * 60
    total + digits_array.second
  end
end