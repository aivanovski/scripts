#!/usr/bin/env ruby

# Script that allows to find merged but not deleted branches in Git repository

def get_log_by_branch_name(branch)
  `git log -n 1 #{branch}`.strip.split("\n")
end

def get_line_from_log(log, name)
  log
    .filter { |line| line.include? name }
    .map { |line| line.gsub(/#{name}:/, '').strip }
    .first
end

branches = `git branch -r --merged | grep -v "HEAD"`.strip.split("\n").map { |branch| branch.strip }

for branch in branches do
  log = get_log_by_branch_name(branch)
  author = get_line_from_log(log, 'Author:')
  date = get_line_from_log(log, 'Date:')
  puts "#{branch}, #{author}, #{date}"
end
