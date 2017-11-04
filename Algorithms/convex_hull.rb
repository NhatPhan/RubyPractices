require './cartesian_points_helper'
require 'benchmark'
require 'matrix'
require 'set'

class ConvexHull
  include CartesianPointsHelper

  attr_reader :points

  FIXNUM_MAX = (2**(0.size * 8 -2) -1)

  def initialize
    setup until points_requirement_satisfied?
  end

  def re_setup
    @points = nil
    setup until points_requirement_satisfied?
  end

  def brute_force
    result = Set.new
    points.each_with_index do |point_a, index_a|
      points[index_a+1..-1].each do |point_b|
        if in_same_plane?(point_a, point_b, points)
          result.merge([point_a, point_b])
        end
      end
    end
    result
  end

  def jarvis_march
    points.sort_by!{ |point| point[1] }
    lowest, highest = points.first, points.last

    result = jarvis_march_wrap(lowest, highest, points, true) +
             jarvis_march_wrap(lowest, highest, points, false)

    result
  end

  def graham_scan
    points.sort!{ |a,b| a[1] <=> b[1] }

    angles = points[1..-1].map { |point_b| [angle_with_line(points[0], point_b), point_b] }
    angles.sort_by!{ |angle| angle[0] }

    result = [points[0]] + angles[0..1].map { |angle| angle[1] }

    angles[2..-1].each do |angle|
      while true
        sub_top_top = vector(result[-2], result[-1])
        sub_top_angle = vector(result[-2], angle[1])

        break if result.size < 2 || determinant(sub_top_top, sub_top_angle) > 0
        result.pop
      end

      result << angle[1]
    end

    result
  end

  def benchmarks
    brute_force_time  = Benchmark.measure { brute_force  }
    jarvis_march_time = Benchmark.measure { jarvis_march }
    graham_scan_time  = Benchmark.measure { graham_scan  }

    puts "Time taken brute forces:  #{brute_force_time.real}"
    puts "Time taken jarvis_march:  #{jarvis_march_time.real}"
    puts "Time taken graham_scan :  #{graham_scan_time.real}"
  end

  private

  def points_requirement_satisfied?
    if points.nil? || points.length < 3
      puts "Requirement: Must have least three points!\n\n"
      return false
    end

    return true
  end

  def determinant(vector_a, vector_b)
    Matrix[vector_a, vector_b].determinant
  end

  def vector(point_a, point_b)
    [point_b[0]-point_a[0],point_b[1]-point_a[1]]
  end

  # Check if all points are in same plane regard to line ab
  def in_same_plane?(point_a, point_b, points)
    return true if points.empty?

    # Initial sign using first point in the list
    vector_ab    = vector(point_a, point_b)
    sign = nil

    # Return false if sign change
    points.each do |point_c|
      next if [point_a,point_b].include? point_c

      vector_ac    = vector(point_a, point_c)
      current_sign = determinant(vector_ab, vector_ac) <=> 0

      sign ||= current_sign
      return false if sign != current_sign
    end

    # Return true if no sign change
    true
  end

  def jarvis_march_wrap(lowest, highest, points, low_to_high = true)
    result = low_to_high ? [lowest] : [highest]

    # Go from lowest to highest
    while true
      point_a = result.last

      # d is the horizontal line from a
      vector_ad = low_to_high ? [1, 0] : [-1, 0]
      selected_point = nil
      min_angle = FIXNUM_MAX

      # Get the point with smallest turn angle
      points.each do |point_b|
        next if (point_b == point_a) ||
                (low_to_high && point_b[1] < point_a[1]) ||
                (!low_to_high && point_b[1] > point_a[1])

        vector_ab = vector(point_a, point_b)
        angle = Vector.elements(vector_ad).angle_with(Vector.elements(vector_ab))
        min_angle, selected_point = [angle, point_b] if angle <= min_angle
      end

      break if [lowest, highest].include? selected_point
      result << selected_point
    end

    result
  end

  def angle_with_line(point_a, point_b, d = [1, 0])
    vector_ab = vector(point_a, point_b)
    Vector.elements(d).angle_with(Vector.elements(vector_ab))
  end
end