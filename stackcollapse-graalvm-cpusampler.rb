#!/usr/bin/env ruby

require 'json'

def gather_samples(data, stack = [], samples = [])
  data.each do |method|
    stack.push method["root_name"]
    method["self_hit_times"].each do |time|
      samples << [stack.dup, time]
    end
    gather_samples(method["children"], stack, samples)
    stack.pop
  end
  samples
end

def dump(data, stack = [])
  data.each do |method|
    stack.push method["root_name"]
    puts "#{stack.join(';')} #{method["self_hit_count"]}"
    dump(method["children"], stack)
    stack.pop
  end
end

timestamp_order = ARGV.delete '--timestamp-order'

data = JSON.load(ARGF.read)
data = data["profile"].flat_map { |thread| thread["samples"] }

if timestamp_order
  gather_samples(data).sort_by { |stack, time| time }.each do |stack, time|
    puts "#{stack.join(';')} 1"
  end
else
  dump(data)
end
