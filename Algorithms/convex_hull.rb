require './cartesian_points_helper'
require 'benchmark'
require 'matrix'
require 'byebug'
require 'set'

class ConvexHull
  include CartesianPointsHelper

  attr_reader :points

  FIXNUM_MAX = (2**(0.size * 8 -2) -1)

  def initialize
    setup until points_requirement_satisfied?
  end

  def reset
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
    points.sort_by!{ |point| point[1] }

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

  def quick_hull
    points.sort_by!{ |point| point[1] }
    low_high = vector(points[0], points[-1])

    left_points = points[1..-2].select do |point|
      determinant(low_high, vector(points[0], point)) > 0
    end
    right_points = points[1..-2].select do |point|
      determinant(low_high, vector(points[0], point)) < 0
    end

    result = [points[0], points[-1]] +
             find_hull(left_points, points[0], points[-1]) +
             find_hull(right_points, points[-1], points[0])

    result
  end

  def benchmarks
    brute_force_time  = Benchmark.measure { brute_force  }

    # Worst case sort when algorithm run
    points.sort_by!{ |point| !point[1] }
    jarvis_march_time = Benchmark.measure { jarvis_march }

    # Worst case sort when algorithm run
    points.sort_by!{ |point| !point[1] }
    graham_scan_time  = Benchmark.measure { graham_scan  }

    # Worst case sort when algorithm run
    points.sort_by!{ |point| !point[1] }
    quick_hull_time  = Benchmark.measure { quick_hull  }

    puts "Time taken brute forces:  #{brute_force_time.real}"
    puts "Time taken jarvis_march:  #{jarvis_march_time.real}"
    puts "Time taken graham_scan :  #{graham_scan_time.real}"
    puts "Time taken quick_hull  :  #{quick_hull_time.real}"
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
    return 0 if vector_ab == [0,0]
    Vector.elements(d).angle_with(Vector.elements(vector_ab))
  end

  def dot_product(point_a, point_b)
    Vector.elements(point_a).dot Vector.elements(point_b)
  end

  def find_hull(points, point_a, point_b)
    return [] if points.empty?

    vector_ab = vector(point_a, point_b)
    sorted_points = points.sort_by { |point_p| determinant(vector_ab, vector(point_a, point_p)).abs }

    point_c   = sorted_points.pop
    vector_ac = vector(point_a, point_c)
    vector_bc = vector(point_b, point_c)

    left_points = sorted_points.select do |point|
      determinant(vector_ac, vector(point_a, point)) > 0
    end
    right_points = sorted_points.select do |point|
      determinant(vector_bc, vector(point_b, point)) < 0
    end

    result = [point_c] +
             find_hull(left_points, point_a, point_c) +
             find_hull(right_points, point_c, point_b)

    result
  end

  # Check if point P is in triangle ABC using barycentric coordinates
  # Read: http://blackpawn.com/texts/pointinpoly/
  def point_in_triangle?(point_p, point_a, point_b, point_c)
    # Compute vectors
    v0 = vector(point_c, point_a)
    v1 = vector(point_b, point_a)
    v2 = vector(point_p, point_a)

    # Compute dot products
    dot00 = dot_product(v0, v0)
    dot01 = dot_product(v0, v1)
    dot02 = dot_product(v0, v2)
    dot11 = dot_product(v1, v1)
    dot12 = dot_product(v1, v2)

    # Compute barycentric coordinates
    inverse_denominator = 1 / (dot00 * dot11 - dot01 * dot01)
    u = (dot11 * dot02 - dot01 * dot12) * inverse_denominator
    v = (dot00 * dot12 - dot01 * dot02) * inverse_denominator

    # Check if point is in triangle
    return (u >= 0) && (v >= 0) && (u + v < 1)
  end
end