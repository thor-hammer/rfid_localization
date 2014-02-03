class Algorithm::PointBased::Zonal < Algorithm::PointBased

  def trainable
    false
  end


  def set_settings(zones_mode = :ellipses, mi_type = nil, mi_threshold = nil)
    @mi_type = mi_type
    @mi_threshold = mi_threshold
    @zones_mode = zones_mode
    self
  end



  private


  def train_model(tags_train_input, height, model_id)
    cache_name = 'elementary_zones_centers_' + @reader_power.to_s + '_' + @zones_mode.to_s
    Rails.cache.fetch(cache_name, :expires_in => 5.days) do
      Algorithm::PointBased::Zonal::ZonesCreator.new(
          @work_zone, @zones_mode, @reader_power
      ).elementary_zones_centers
    end
  end

  def model_run_method(zones, setup, tag)
    tag_data = tag.answers[:a][:average].dup
    if @mi_type.present?
      tag.answers[:a][:average].keys.each do |antenna|
        tag_data[antenna] = 0 if tag.answers[@mi_type][:average][antenna].to_f <= @mi_threshold
      end
      tag_data = tag.answers[:a][:average].dup if tag_data.values.all?{|e| e == 0}
    end
    estimate = make_estimate(zones, tag_data, tag)
    remove_bias(tag, setup, estimate)
  end









  def make_estimate(zones, tag_data, tag)
    antennas = tag_data.select{|k,v| v == 1}.keys

    found_zones = []
    antennas.length.downto(1) do |length|
      combinations = antennas.combination(length)
      combinations.each do |combination|
        if zones.keys.include? (combination.to_s)
          found_zones.push zones[combination.to_s]
        end
      end
      break unless found_zones.empty?
    end

    return Point.new(0,0) if found_zones.empty?
    Point.center_of_points found_zones
  end
end