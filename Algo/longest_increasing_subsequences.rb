def main(*arr)
  edges = create_dag_edges(arr) # create dag from smaller to larger item
  lis_dp = Hash.new # dynamic programming storage

  results = []
  arr.each_index { |i| results << lis(i, edges, lis_dp) }

  print_results(results, arr)
end

def create_dag_edges(arr)
  edges = Hash.new
  arr.each_index do |i|
    edges[i] = []
    arr.each_index do |j|
      break unless j < i
      edges[i] << j if arr[j] < arr[i]
    end
  end
  edges
end

def lis(i, edges, lis_dp)
  return lis_dp[i] unless lis_dp[i].nil?

  longest_value, longest_index = 0, nil
  edges[i].each_index do |j|
    current_longest = lis(j, edges, lis_dp)[0]
    if current_longest > longest_value
      longest_value, longest_index = current_longest, j
    end
  end
  lis_dp[i] = [1 + longest_value, longest_index]
  lis_dp[i]
end

def print_results(results, arr)
  value, index = results.map{ |result| result[0] }.each_with_index.max
  sequences = [index]

  previous_vertex = results[index][1]
  while !previous_vertex.nil?
    sequences << previous_vertex
    previous_vertex = results[previous_vertex][1]
  end

  puts "Longest Sequence: #{value}"
  puts 'Sequences: '
  p sequences.reverse.map { |index| arr[index] }
end

# Instruction to run:
# ruby -r "./longest_increasing_subsequences.rb" -e "main 5,2,8,6,3,6,9,7"