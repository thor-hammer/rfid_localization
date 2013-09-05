class Algorithm::PointBased::Combinational < Algorithm::PointBased
  def set_settings(algorithms, weights = [])
    @algorithms = algorithms
    @weights = weights
    self
  end


  private

  def save_in_file_by_external_mechanism
    false
  end



  def calc_tags_output
    tags_estimates = {}

    TagInput.tag_ids.each do |tag_index|
      tag = @tags_test_input[tag_index]
      tag_estimate = make_estimate(tag_index)
      tag_output = TagOutput.new(tag, tag_estimate)
      tags_estimates[tag_index] = tag_output
    end

    tags_estimates
  end

  def make_estimate(tag_index)
    return Point.new(nil,nil) if @tags_test_input[tag_index].nil?

    antennae_count_tag_answered_to = @tags_test_input[tag_index].answers_count

    points_hash = {}
    weights = []
    @algorithms.each_with_index do |algorithm, index|
      unless algorithm[tag_index].nil?
        points_hash[ algorithm[tag_index][:test_estimate].to_s ] ||= 0
        points_hash[ algorithm[tag_index][:test_estimate].to_s ] += 1
        unless @weights.empty? or @weights[antennae_count_tag_answered_to].nil?
          weights.push @weights[antennae_count_tag_answered_to][index]
        end
      end
    end

    return nil if points_hash.empty?

    unless weights.empty?
      weights_sum = weights.inject(&:+)
      weights = weights.map{|e| e / weights_sum} if weights_sum != 1.0
    end

    points = points_hash.keys.map{|point_string| Point.from_s(point_string)}
    Point.center_of_points(points, weights)
  end
end