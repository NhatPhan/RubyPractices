module CartesianPointsHelper
  def setup
    puts 'How do you want to set inputs: '
    puts '1. Manually      2. Auto Generated      3. Default'

    method = gets.to_i

    until (1..3) === method
      puts 'Must input number 1 or 2 or 3! Enter again: '
      method = gets.to_i
    end

    case method
      when 1
        @points = get_points_manually
      when 2
        @points = get_points_automatically
      when 3
        @points = default_points
    end
  end

  private

  def get_points_manually
    puts 'Enter desired number of points: '
    @points_length = gets.to_i

    points = Array.new(@points_length, Array.new(2))

    puts 'Enter coordinates for each point: (e.g. 2 5)'
    points.each_index { |index| points[index] = gets.split.map(&:to_f) }

    points
  end

  def get_points_automatically
    puts 'Enter desired number of points: '
    @points_length = gets.to_i

    points = Array.new(@points_length, Array.new(2))
    points.each_index { |index| points[index] = [rand(-50.0..50.0), rand(-50.0..50.0)] }
  end

  def default_points
    [[0.0, 1.0], [1.0, 2.0], [2.0, 3.0], [3.0, 4.0], [-1.0, -2.0],
     [-3.0, -4.0], [-5.0, -6.0], [7.0, 8.0], [-4.0, 10.0], [2.0, -1.0]]
  end
end