#!/usr/bin/env ruby
File.open('input.inc','w') { |f| f.write "INPUT:\n#{File.read('input.txt').split.map { |i| "    dc.w #{i}" }.join("\n")}\nINPUTEND:" }

