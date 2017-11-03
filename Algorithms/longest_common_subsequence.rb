# Constant directions to trace back common substrings
DIRECTIONS = { up: 1, left: 2, diagonal: 3 }

def main(a, b)
  solutions = setup(a, b)
  lcs(a, b, solutions)

  puts "Longest Common Substring: #{get_lcs_string(solutions, a, b)}"
end

# Setup DP storage
def setup(a, b)
  solutions = Array.new(a.length + 1) { Array.new(b.length + 1) { Array.new(2, nil) } }
  solutions[0][0][0] = 0

  (0..a.length).each { |row| solutions[row][0][0] = 0 }
  (1..b.length).each { |col| solutions[0][col][0] = 0 }

  solutions
end

def lcs(a, b, solutions)
  (1..a.length).each do |i|
    (1..b.length).each do |j|
      if a[i-1] == b[j-1]
        solutions[i][j] = [1 + solutions[i-1][j-1][0], DIRECTIONS[:diagonal]]
      else
        solutions[i][j] = solutions[i][j-1][0] > solutions[i-1][j][0] ?
                              [solutions[i][j-1][0], DIRECTIONS[:left]] :
                              [solutions[i-1][j][0], DIRECTIONS[:up]]
      end
    end
  end
end

# Follow the directions to get the common substring
def get_lcs_string(solutions, a, b)
  lcs_string = []
  row, col = a.length, b.length

  while true
    direction = solutions[row][col][1]
    break if direction.nil?

    if a[row - 1] == b[col - 1]
      lcs_string << a[row - 1]
      row, col = row - 1, col - 1
    else
      direction == DIRECTIONS[:left] ? col -= 1 : row -= 1
    end
  end

  lcs_string.reverse.join
end

# Instruction to run:
# ruby -r "./longest_common_subsequence.rb" -e "main 'cat','shat'"