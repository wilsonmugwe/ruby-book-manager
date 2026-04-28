# Main launcher for the Ruby Book Collection Manager.
# This file allows the user to choose between the CLI and GUI versions.

puts "========================================"
puts " Ruby Book Collection Manager"
puts "========================================"
puts "1. Run Command-Line Interface (CLI)"
puts "2. Run Graphical User Interface (GUI)"
puts "3. Exit"
print "Choose an option: "

choice = gets.chomp

case choice
when "1"
  require_relative "cli_app"
when "2"
  require_relative "gui_app"
when "3"
  puts "Goodbye."
else
  puts "Invalid option. Please run the program again and choose 1, 2, or 3."
end