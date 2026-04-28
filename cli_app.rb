require_relative "book"
require_relative "book_manager"

# Command-line interface for the Ruby Book Collection Manager.
class CLIApp
  def initialize
    @manager = BookManager.new
  end

  def run
    loop do
      puts "\n===== CLI Book Collection Manager ====="
      puts "1. Add Book"
      puts "2. View All Books"
      puts "3. Search Book"
      puts "4. Delete Book"
      puts "5. Exit to Main Program"
      print "Choose an option: "

      choice = gets.chomp

      case choice
      when "1"
        add_book
      when "2"
        view_books
      when "3"
        search_books
      when "4"
        delete_book
      when "5"
        puts "Exiting CLI version."
        break
      else
        puts "Invalid option. Please choose from 1 to 5."
      end
    end
  end

  private

  def add_book
    print "Enter book title: "
    title = gets.chomp

    print "Enter author: "
    author = gets.chomp

    print "Enter genre: "
    genre = gets.chomp

    print "Enter publication year: "
    year = gets.chomp

    if title.empty? || author.empty? || genre.empty? || year.empty?
      puts "Error: all fields are required."
      return
    end

    book = Book.new(title, author, genre, year)
    @manager.add_book(book)

    puts "Book added successfully."
  end

  def view_books
    books = @manager.view_books

    if books.empty?
      puts "No books found."
    else
      puts "\n--- Book Collection ---"
      books.each_with_index do |book, index|
        puts "#{index + 1}. #{book.display}"
      end
    end
  end

  def search_books
    print "Enter search keyword: "
    keyword = gets.chomp

    results = @manager.search_books(keyword)

    if results.empty?
      puts "No matching books found."
    else
      puts "\n--- Search Results ---"
      results.each_with_index do |book, index|
        puts "#{index + 1}. #{book.display}"
      end
    end
  end

  def delete_book
    books = @manager.view_books

    if books.empty?
      puts "No books to delete."
      return
    end

    view_books

    print "Enter book number to delete: "
    number = gets.chomp.to_i

    if @manager.delete_book(number - 1)
      puts "Book deleted successfully."
    else
      puts "Invalid book number."
    end
  end
end

CLIApp.new.run