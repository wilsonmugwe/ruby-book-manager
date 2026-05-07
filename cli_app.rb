# ===============================================================
# File Name: cli_app.rb
# Class Name: CLIApp
# Purpose:
# This file provides a command-line interface version of the
# Book Collection Manager application.
# It uses the same Book and BookManager classes as the web version,
# demonstrating Ruby's flexibility across both CLI and web systems.
# ===============================================================

require_relative "book"
require_relative "book_manager"

class CLIApp
  def initialize
    @manager = BookManager.new
    @username = nil
  end

  # -------------------------------------------------------------
  # Method Name: run
  # Purpose:
  # Starts the CLI program by asking for a username, then repeatedly
  # displays the menu until the user chooses to exit.
  # -------------------------------------------------------------
  def run
    login_cli_user

    loop do
      puts "\n===== CLI Book Collection Manager ====="
      puts "Logged in as: #{@username}"
      puts "1. Add Book"
      puts "2. View My Books"
      puts "3. Search My Books"
      puts "4. Delete My Book"
      puts "5. Exit CLI"
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

  # -------------------------------------------------------------
  # Method Name: login_cli_user
  # Purpose:
  # Collects a username for the CLI session.
  # This username becomes the owner of all books added through CLI.
  # -------------------------------------------------------------
  def login_cli_user
    loop do
      print "Enter your username to start CLI session: "
      input = gets.chomp.strip

      if input.empty?
        puts "Username cannot be empty."
      else
        @username = input
        puts "CLI session started for #{@username}."
        break
      end
    end
  end

  # -------------------------------------------------------------
  # Method Name: add_book
  # Purpose:
  # Collects book details, validates input, creates a Book object,
  # assigns the current CLI username as owner, and saves the record.
  # -------------------------------------------------------------
  def add_book
    print "Enter book title: "
    title = gets.chomp.strip

    print "Enter author: "
    author = gets.chomp.strip

    print "Enter genre: "
    genre = gets.chomp.strip

    print "Enter publication year: "
    year = gets.chomp.strip

    if title.empty? || author.empty? || genre.empty? || year.empty?
      puts "Error: all fields are required."
      return
    end

    book = Book.new(title, author, genre, year, @username)
    @manager.add_book(book)

    puts "Book added successfully."
  end

  # -------------------------------------------------------------
  # Method Name: view_books
  # Purpose:
  # Displays only the books owned by the current CLI user.
  # -------------------------------------------------------------
  def view_books
    books = @manager.books_for_user(@username)

    if books.empty?
      puts "No books found for #{@username}."
    else
      puts "\n--- #{@username}'s Book Collection ---"

      books.each_with_index do |book, index|
        puts "#{index + 1}. #{book.display}"
      end
    end
  end

  # -------------------------------------------------------------
  # Method Name: search_books
  # Purpose:
  # Searches only the current user's books using BookManager's
  # username-aware search method.
  # -------------------------------------------------------------
  def search_books
    print "Enter search keyword: "
    keyword = gets.chomp.strip

    results = @manager.search_books(keyword, @username)

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
  # Deletes a selected book belonging only to the current CLI user.
  # -------------------------------------------------------------
  def delete_book
    books = @manager.books_for_user(@username)

    if books.empty?
      puts "No books to delete."
      return
    end

    view_books

    print "Enter book number to delete: "
    number = gets.chomp.to_i

    if @manager.delete_user_book(number - 1, @username)
      puts "Book deleted successfully."
    else
      puts "Invalid book number."
    end
  end
end

CLIApp.new.run