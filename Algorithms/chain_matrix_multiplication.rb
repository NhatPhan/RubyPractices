require 'benchmark'

FIXNUM_MAX = (2**(0.size * 8 -2) -1)

def main
  puts 'Choose your preferred method to input matrix dimensions: '
  puts '1. Manually     2. Auto-generated'

  method = gets.to_i
  abort('Must input number 1 or 2! Aborting...') unless [1,2].include?(method)

  n, matrices = (method == 1) ? get_inputs_manually : get_inputs_random
  solutions = setup_solutions(n)

  top_down_time = Benchmark.measure {
    min_cost_top_down(solutions, matrices, 1, n)
  }

  bottom_up_time = Benchmark.measure {
    min_cost_bottom_up(solutions, matrices, n)
  }

  print_results(solutions, n)
  puts "Time taken top-down: #{top_down_time.real}"
  puts "Time taken bottom-up: #{bottom_up_time.real}"
end

def get_inputs_manually
  puts 'Enter number of matrices: '
  n = gets.to_i

  matrices = Hash.new
  (1..n).each do |i|
    puts "two dimensions of matrix #{i} (separated by space): "
    matrices[i] = gets.split.map(&:to_i)

    abort('Mismatched dimensions! Aborting...') if i > 1 && matrices[i][0] != matrices[i-1][1]
  end

  [n, matrices]
end

def get_inputs_random
  puts 'Enter number of matrices: '
  n = gets.to_i

  matrices = Hash.new
  matrices[1] = [1 + rand(100), 1 + rand(100)]
  (2..n).each { |i| matrices[i] = [matrices[i-1][1], 1 + rand(100)] }

  [n, matrices]
end

def setup_solutions(n)
  solutions = Array.new(n + 1){ Array.new(n + 1) { [nil, nil] } }

  solutions[0][0][0] = 0
  (1..n).each { |i| solutions[0][i][0] = solutions[i][0][0] = solutions[i][i][0] = 0 }

  solutions
end

def min_cost_top_down(solutions, matrices, i, j)
  return [0, nil] if i == j

  result= solutions[i][j][0] || FIXNUM_MAX
  best_cut = solutions[i][j][1]

  (i..j-1).each do |k|
    solutions[i][k][0] ||= min_cost_top_down(solutions, matrices, i, k)
    solutions[k+1][j][0] ||= min_cost_top_down(solutions, matrices, k + 1, j)

    current_min = solutions[i][k][0] + solutions[k+1][j][0] +
                  matrices[i][0] * matrices[k][1] * matrices[j][1]

    result, best_cut = current_min, k if current_min < result
  end

  best_cut = nil if j - i == 1
  solutions[i][j] = [result, best_cut]
end

def min_cost_bottom_up(solutions, matrices, n)
  (1..n-1).each do |l|
    (1..n-l).each do |i|
      j = i + l
      result= solutions[i][j][0] || FIXNUM_MAX
      best_cut = solutions[i][j][1]
      (i..(j-1)).each do |k|
        current_min = solutions[i][k][0] + solutions[k+1][j][0] +
            matrices[i][0] * matrices[k][1] * matrices[j][1]

        result, best_cut = current_min, k if current_min < result
      end
      solutions[i][j] = [result, best_cut]
    end
  end
end

def print_results(solutions, n)
  puts "Minimum Cost: #{solutions[1][n][0]}"
  cuts = get_cuts(solutions, 1, n)
  puts "Cuts at: #{cuts.join(' ')}"
end

def get_cuts(solutions, i, j)
  cut = solutions[i][j][1]
  return [] if cut.nil?

  unprocessed_cuts = [cut]
  cuts = []

  while !unprocessed_cuts.empty?
    cut = unprocessed_cuts.pop
    cuts << cut

    unprocessed_cuts << solutions[i][cut][1]
    unprocessed_cuts << solutions[cut+1][j][1]

    unprocessed_cuts.compact!
    unprocessed_cuts.delete_if { |cut| cuts.include?(cut) }
  end

  cuts
end