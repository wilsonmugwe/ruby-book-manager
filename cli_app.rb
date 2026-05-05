# ===============================================================
# File Name: cli_app.rb
# Class Name: CLIApp
# Purpose:
# This file provides a command-line interface version of the
# Book Collection Manager application.
# It allows users to interact with the same Book and BookManager
# classes through terminal input/output instead of a web browser.
# This demonstrates Ruby's flexibility in supporting both
# console-based and web-based software interfaces.
# ===============================================================

require_relative "book"          # Imports the Book data model
require_relative "book_manager"  # Imports the BookManager logic engine

# ---------------------------------------------------------------
# Class Name: CLIApp
# Purpose:
# Controls all terminal-based user interaction and menu navigation.
# ---------------------------------------------------------------
class CLIApp

  # Constructor creates one BookManager object for all CLI actions
  def initialize
    @manager = BookManager.new
  end

  # -------------------------------------------------------------
  # Method Name: run
  # Purpose:
  # Displays the main CLI menu repeatedly until the user chooses
  # to exit. Uses a loop and case statement to process commands.
  # -------------------------------------------------------------
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

      # Case control structure routes the user to the selected action
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

  # -------------------------------------------------------------
  # Method Name: add_book
  # Purpose:
  # Collects book information from terminal prompts, validates
  # input fields, creates a Book object, and sends it to the
  # BookManager for storage.
  # -------------------------------------------------------------
  def add_book
    print "Enter book title: "
    title = gets.chomp

    print "Enter author: "
    author = gets.chomp

    print "Enter genre: "
    genre = gets.chomp

    print "Enter publication year: "
    year = gets.chomp

    # Validation prevents incomplete records from being created
    if title.empty? || author.empty? || genre.empty? || year.empty?
      puts "Error: all fields are required."
      return
    end

    # Creates a new Book object and adds it to persistent storage
    book = Book.new(title, author, genre, year)
    @manager.add_book(book)

    puts "Book added successfully."
  end

  # -------------------------------------------------------------
  # Method Name: view_books
  # Purpose:
  # Displays every stored book currently available in the JSON
  # collection file.
  # -------------------------------------------------------------
  def view_books
    books = @manager.view_books

    if books.empty?
      puts "No books found."
    else
      puts "\n--- Book Collection ---"

      # each_with_index prints a numbered list for easier reading
      books.each_with_index do |book, index|
        puts "#{index + 1}. #{book.display}"
      end
    end
  end

  # -------------------------------------------------------------
  # Method Name: search_books
  # Purpose:
  # Accepts a keyword from the user and displays all matching
  # books found through the BookManager search method.
  # -------------------------------------------------------------
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

  # -------------------------------------------------------------
  # Method Name: delete_book
  # Purpose:
  # Allows the user to remove a selected book by entering its
  # displayed number from the collection list.
  # -------------------------------------------------------------
  def delete_book
    books = @manager.view_books

    if books.empty?
      puts "No books to delete."
      return
    end

    # First displays all books so the user can choose correctly
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

# ---------------------------------------------------------------
# Program Execution Entry Point
# Purpose:
# Creates the CLIApp object and starts the terminal application.
# ---------------------------------------------------------------
CLIApp.new.run