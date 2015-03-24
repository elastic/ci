#!/usr/bin/env ruby
require 'levenshtein'

puts Levenshtein.normalized_distance 'bill.hwang', 'billh'
puts Levenshtein.normalized_distance 'bill.hwang', 'arraont'
# Read files
file_one = ARGV[0]
file_two = ARGV[1]
puts file_one, file_two
file_one_content = File.readlines(file_one)
file_two_content = File.readlines(file_two)
require 'yaml'
puts YAML.dump file_two_content
puts YAML.dump file_two_content[0]


result = file_one_content.map do |current_one|
   third_content = file_two_content.select do |x|
     current_one[0] == x[0]
   end
   score = third_content.map do |current_two|
     first_one = current_one.split('@').first
     second_one = current_two.split('@').first
     [current_two, (Levenshtein.normalized_distance second_one, first_one)]
   end.sort { |x, y| x[1] <=> y[1] }
   puts YAML.dump(score)
   [current_one.chomp, score.first.first.chomp]
end

puts YAML.dump(result)
puts result.map {|x| x[1] }
