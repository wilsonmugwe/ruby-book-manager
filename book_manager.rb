# ===============================================================
# File Name: book_manager.rb
# Class Name: BookManager
# Purpose:
# This class acts as the central processing controller of the
# Book Collection Manager application.
# It is responsible for:
# - storing all Book objects in memory
# - adding new books
# - viewing records
# - filtering books for individual users
# - searching records by keyword
# - deleting selected books
# - saving all records to JSON persistent storage
# - loading records back into the system on startup
# ===============================================================

require "json"              # Ruby library used for JSON file handling
require_relative "book"     # Imports the Book class for object creation

class BookManager

  # Constant variable storing the external file used for persistence
  FILE_NAME = "books.json"

  # ---------------------------------------------------------------
  # Constructor Method: initialize
  # Purpose:
  # Creates an empty in-memory array for all books and immediately
  # loads previously saved records from the JSON file.
  # This ensures that data is not lost between executions.
  # ---------------------------------------------------------------
  def initialize
    @books = []     # Internal array used to hold Book objects
    load_books      # Load previously stored data at startup
  end

  # ---------------------------------------------------------------
  # Method Name: add_book
  # Purpose:
  # Receives a new Book object from the GUI and appends it to the
  # internal collection, then immediately saves changes to file.
  # ---------------------------------------------------------------
  def add_book(book)
    @books << book
    save_books
  end

  # ---------------------------------------------------------------
  # Method Name: view_books
  # Purpose:
  # Returns the full list of all books currently stored in memory.
  # Used when the GUI needs to display every available record.
  # ---------------------------------------------------------------
  def view_books
    @books
  end

  # ---------------------------------------------------------------
  # Method Name: books_for_user
  # Purpose:
  # Filters the global book collection and returns only the books
  # that belong to the currently logged-in user.
  # This supports role-based personalised viewing.
  # ---------------------------------------------------------------
  def books_for_user(username)
    @books.select do |book|
      book.owner == username
    end
  end

  # ---------------------------------------------------------------
  # Method Name: search_books
  # Purpose:
  # Searches through a specific user's books using a keyword.
  # The search checks title, author and genre fields while ignoring
  # uppercase/lowercase differences.
  # ---------------------------------------------------------------
  def search_books(keyword, username)
    keyword = keyword.to_s.downcase

    books_for_user(username).select do |book|
      book.title.downcase.include?(keyword) ||
        book.author.downcase.include?(keyword) ||
        book.genre.downcase.include?(keyword)
    end
  end

  # ---------------------------------------------------------------
  # Method Name: delete_user_book
  # Purpose:
  # Deletes a selected book belonging to the logged-in user using
  # its displayed index position in the GUI list.
  # Returns true if deletion succeeds and false if invalid.
  # ---------------------------------------------------------------
  def delete_user_book(index, username)
    user_books = books_for_user(username)
    book_to_delete = user_books[index]

    return false unless book_to_delete

    @books.delete(book_to_delete)
    save_books
    true
  end

  # ---------------------------------------------------------------
  # Method Name: save_books
  # Purpose:
  # Converts every Book object into hash format and writes the
  # complete collection into the JSON file using pretty formatting.
  # This creates permanent external storage for all records.
  # ---------------------------------------------------------------
  def save_books
    File.write(FILE_NAME, JSON.pretty_generate(@books.map(&:to_hash)))
  end

  # ---------------------------------------------------------------
  # Method Name: load_books
  # Purpose:
  # Loads previously saved JSON data when the program starts.
  # If the JSON file exists, all records are parsed and converted
  # back into Book objects.
  # If the file does not exist, a new empty JSON file is created.
  # Error handling is included for corrupted JSON content.
  # ---------------------------------------------------------------
  def load_books
    if File.exist?(FILE_NAME)
      data = JSON.parse(File.read(FILE_NAME))
      @books = data.map { |book_data| Book.from_hash(book_data) }
    else
      File.write(FILE_NAME, "[]")
      @books = []
    end

  rescue JSON::ParserError
    puts "Error: books.json is corrupted. Starting with an empty collection."
    @books = []
  end
end