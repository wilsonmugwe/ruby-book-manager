require_relative "book"
require_relative "book_manager"

manager = BookManager.new

loop do
  puts "\n===== Ruby Book Collection Manager ====="
  puts "1. Add Book"
  puts "2. View All Books"
  puts "3. Search Book"
  puts "4. Delete Book"
  puts "5. Exit"
  print "Choose an option: "

  choice = gets.chomp

  case choice
  when "1"
    print "Enter book title: "
    title = gets.chomp

    print "Enter author: "
    author = gets.chomp

    print "Enter genre: "
    genre = gets.chomp

    print "Enter publication year: "
    year = gets.chomp

    book = Book.new(title, author, genre, year)
    manager.add_book(book)

    puts "Book added successfully."

  when "2"
    books = manager.view_books

    if books.empty?
      puts "No books found."
    else
      puts "\n--- Book Collection ---"
      books.each_with_index do |book, index|
        puts "#{index + 1}. #{book.display}"
      end
    end

  when "3"
    print "Enter search keyword: "
    keyword = gets.chomp

    results = manager.search_books(keyword)

    if results.empty?
      puts "No matching books found."
    else
      puts "\n--- Search Results ---"
      results.each_with_index do |book, index|
        puts "#{index + 1}. #{book.display}"
      end
    end

  when "4"
    books = manager.view_books

    if books.empty?
      puts "No books to delete."
    else
      puts "\n--- Book Collection ---"
      books.each_with_index do |book, index|
        puts "#{index + 1}. #{book.display}"
      end

      print "Enter book number to delete: "
      number = gets.chomp.to_i

      if manager.delete_book(number - 1)
        puts "Book deleted successfully."
      else
        puts "Invalid book number."
      end
    end

  when "5"
    puts "Goodbye."
    break

  else
    puts "Invalid option. Please choose from 1 to 5."
  end
end