module CartesianPointsHelper
  def setup
    puts 'Do you want to input points manually: '
    puts '1. Yes      2. No'

    method = gets.to_i

    until (1..2) === method
      puts 'Must input number 1 or 2! Enter again: '
      method = gets.to_i
    end

    puts 'Enter desired number of points: '
    @points_length = gets.to_i

    @points = (method == 1) ? get_points_manually : get_points_automatically
  end

  private

  def get_points_manually
    points = Array.new(@points_length, Array.new(2))

    puts 'Enter coordinates for each point: (e.g. 2 5)'
    points.each_index { |index| points[index] = gets.split.map(&:to_f) }

    points
  end

  def get_points_automatically
    points = Array.new(@points_length, Array.new(2))
    points.each_index { |index| points[index] = [rand(-50.0..50.0), rand(-50.0..50.0)] }
  end
end