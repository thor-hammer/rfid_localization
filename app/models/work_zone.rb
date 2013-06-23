class WorkZone
  attr_accessor :width, :height, :antennae, :reader_power

  def initialize(reader_power, x = 500, y = 500, antennae_count = 16)
    @reader_power = reader_power
    @width = x
    @height = y

    @antennae = {}
    1.upto(antennae_count) do |number|
      @antennae[number] = Antenna.new(number, Zone::POWERS_TO_SIZES[reader_power])
    end
  end
end