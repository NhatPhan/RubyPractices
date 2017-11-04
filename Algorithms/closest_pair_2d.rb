require 'priority_queue'
require 'benchmark'
require './cartesian_points_helper'

class ClosestPair2D
  include CartesianPointsHelper

  attr_accessor :points

  FIXNUM_MAX = (2**(0.size * 8 -2) -1)

  def initialize
    setup
  end

  def re_setup
    setup
  end

  def brute_force
    brute_force_sub_routine(points)
  end

  # Divide and Conquer (DAC) with only x coordinates sorted
  def divide_and_conquer_sorted_x
    points.sort_by!{ |point| point[0] }
    dac_sorted_x_recursively(points)
  end

  # Divide and Conquer (DAC) with x and y coordinates sorted
  def divide_and_conquer_sorted_xy
    points.sort_by!{ |point| point[0] }

    points_y_sorted = Hash.new
    points.sort_by{ |point| point[1] }.each do |point|
      points_y_sorted[point[0]] = [point, nil]
    end

    dac_sorted_xy_recursively(points, points_y_sorted)
  end

  def benchmarks
    brute_force_time = Benchmark.measure { brute_force }
    dac_sorted_x_time  = Benchmark.measure { divide_and_conquer_sorted_x }
    dac_sorted_xy_time  = Benchmark.measure { divide_and_conquer_sorted_xy }

    puts "Time taken brute forces: #{brute_force_time.real}"
    puts "Time taken DAC with only x sorted: #{dac_sorted_x_time.real}"
    puts "Time taken DAC with x and y sorted: #{dac_sorted_xy_time.real}"
  end

  private

  def euclidean_distance(point_a, point_b)
    Math.sqrt((point_a[0] - point_b[0]) ** 2 + (point_a[1] - point_b[1]) ** 2)
  end

  def brute_force_sub_routine(points)
    result = FIXNUM_MAX

    points.each_with_index do |point_a, index|
      points[index + 1..-1].each do |point_b|
        result = [euclidean_distance(point_a, point_b), result].min
      end
    end

    result
  end

  ## Divide and Conquer (DAC) procedures with only x coordinates sorted
  def dac_sorted_x_recursively(points)
    return brute_force_sub_routine(points) if points.length <= 3

    delta = [
        dac_sorted_x_recursively(points[0..points.length/2]),
        dac_sorted_x_recursively(points[points.length/2 + 1..points.length - 1])
    ].min

    dac_sorted_x_merge(points, delta)
  end
  def dac_sorted_x_merge(points, delta)
    middle_line_x = points[points.length/2][0]

    strip_points = points.select{ |point| point[0] - middle_line_x <= delta }
    strip_points.sort_by!{ |point| point[1] }

    dac_merge(strip_points, delta)
  end


  ## Divide and Conquer (DAC) procedures with x and y coordinates sorted
  def dac_sorted_xy_recursively(points, points_y_sorted)
    return brute_force_sub_routine(points) if points.length <= 3

    points[0..points.length/2].each do |point|
      points_y_sorted[point[0]][1] = 'L'
    end

    points[points.length/2 + 1..points.length - 1].each do |point|
      points_y_sorted[point[0]][1] = 'R'
    end

    points_y_sorted_left = points_y_sorted.select{ |x, point| point[1] == 'L' }
    points_y_sorted_right = points_y_sorted.select{ |x, point| point[1] == 'R' }

    delta = [
      dac_sorted_xy_recursively(points[0..points.length/2], points_y_sorted_left),
      dac_sorted_xy_recursively(points[points.length/2 + 1..points.length - 1], points_y_sorted_right)
    ].min

    dac_sorted_xy_merge(points_y_sorted, delta, points[points.length/2][0])
  end
  def dac_sorted_xy_merge(points_y_sorted, delta, middle_line_x)
    strip_points = []

    points_y_sorted.each do |x, point|
      strip_points << point[0] if x - middle_line_x <= delta
    end

    dac_merge(strip_points, delta)
  end

  ## Compare delta (min of two divided parts) with strip points
  def dac_merge(strip_points, delta)
    result = delta

    strip_points.each_with_index do |point_a, index|
      # Maximum next points need to check is 7
      # Proof: http://people.csail.mit.edu/indyk/6.838-old/handouts/lec17.pdf
      end_bound = [strip_points.length, index + 7].min

      strip_points[index+1..end_bound].each do |point_b|
        result = [ euclidean_distance(point_a, point_b), result].min
      end
    end

    result
  end
end