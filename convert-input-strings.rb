#!/usr/bin/env ruby
File.open('input.inc','w') { |f| f.write "INPUT:\n#{File.read('input.txt').split(/\n/).map { |i| %{    dc.b "#{i}", 13} }.join("\n")},0\nINPUTEND:" }

