def main(length, *prices)
  # Convention: prices must start from length 0 (easy indexing)
  prices_length = prices.length

  # Dynamic Programming solutions keep index and optimal price
  # For length <= prices.length set default value (no cut)
  solutions = Array.new(length + 1)
  solutions.each_index do |index|
    solutions[index] = index <= (prices_length - 1) ? [index, prices[index]] : [nil, -1]
  end

  # Bottom up approach
  (1..length).each do |l|
    optimal_cut(l, solutions)
  end

  # Print the optimal price with cuts
  print_solutions(length, solutions)
end

def optimal_cut(length, solutions)
  (1..length).each do |l1|
    total_cuts_price = solutions[l1][1] + solutions[length - l1][1]
    solutions[length] = [l1, total_cuts_price] if total_cuts_price > solutions[length][1]
  end
end

def print_solutions(length, solutions)
  puts "Maximum price: #{solutions[length][1]}"

  l1_cut = solutions[length][0]
  l2_cut = length - l1_cut

  cuts = cuts(l1_cut, length, solutions, 0) + cuts(l2_cut, length, solutions, l1_cut)
  cuts.delete(length) # last cut is not needed

  p cuts.empty? ? 'No cut' : "Cuts: #{cuts}"
end

# Print the cuts at 'cut' with length 'length'
# The offset is use to calculate cut at second half, its value is first half cut
def cuts(cut, length, solutions, offset)
  cuts = []
  while cut != length
    cuts << (cut + offset)
    length, cut = cut, solutions[cut][0]
  end
  cuts
end

# rod length is 30.
# length: 0 1 2 3 4  5  6  7  8
# prices: 0 1 5 8 9 10 17 17 20

# Instruction to run:
# ruby -r "./rod_cutting.rb" -e "main 30,0,1,5,8,9,10,17,17,20"