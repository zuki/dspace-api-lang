#!/usr/bin/env ruby

class Message
  attr_reader :name, :h

  def initialize(file)
    @file = file
    @name = File.basename(file)
  end

  def parse
    continue = false
    key = value = ''
    lno = 0
    @h = Hash.new
    open(@file) do |f|
      while line = f.gets
        lno += 1
        line = line.chomp
        if /^\s*$/ =~ line or /^\s*#/ =~ line
          next
        elsif continue
          if line.end_with? "\\"
            value += line + "\n"
          else
            value += line
            h[key] = value
            continue = false
          end
        else
          if /^([^=]+)=(.*)$/ =~ line
            key = $1.strip
            value = $2.strip
            if value.end_with? "\\"
              value += "\n"
              continue = true
            else
              h[key] = value
            end
          else
            raise "invalid line: #{lno}: #{line}"
          end
        end
      end
    end
  end

  def check_to(target)
    puts "IN #{@name} BUT NOT IN #{target.name}"
    @h.each do |key, value|
      puts "#{key} = #{value}" unless target.h.has_key?(key)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if (ARGV.length != 2)
    puts "Usage: check_diff <master> <tocheck>"
    exit
  end

  [ARGV[0], ARGV[1]].each do |file|
    unless File.readable?(file)
      puts "#{file} can not open"
      exit
    end
  end

  m1 = Message.new(ARGV[0])
  m2 = Message.new(ARGV[1])
  begin
    m1.parse
    m2.parse
  rescue => e
    puts "Error: #{e.message}"
    exit
  end

  m1.check_to(m2)
  puts ""
  m2.check_to(m1)
end
