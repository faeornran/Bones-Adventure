#!/usr/env ruby
#

results = [0] * 20
rolls = 200000000
average = rolls/20

rolls.times do |m|
  roll = rand(20)
  results[roll] += 1
end

20.times do |i|
  j = i+1
  if j < 10
    j = " " + j.to_s
  else
    j = j.to_s
  end
  percent = (results[i-1] - average)
  percent = percent.to_f
  percent = 100 * (percent / average.to_f)
  percent = percent.to_s
  if percent =~ /-/
    #
  else
    percent = "+" + percent
  end
  puts j.to_s + ": " + results[i-1].to_s + "\t #{percent}%"
end