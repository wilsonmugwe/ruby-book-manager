require "json"
require_relative "book"

# Handles book storage, searching, deletion and JSON file operations
class BookManager
  FILE_NAME = "books.json"

  def initialize
    @books = []
    load_books
  end

  def add_book(book)
    @books << book
    save_books
  end

  def view_books
    @books
  end

  def search_books(keyword)
    @books.select do |book|
      book.title.downcase.include?(keyword.downcase) ||
      book.author.downcase.include?(keyword.downcase) ||
      book.genre.downcase.include?(keyword.downcase)
    end
  end

  def delete_book(index)
    return false if index < 0 || index >= @books.length

    @books.delete_at(index)
    save_books
    true
  end

  def save_books
    File.write(FILE_NAME, JSON.pretty_generate(@books.map(&:to_hash)))
  end

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