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

  def books_for_user(username)
    @books.select do |book|
      book.owner == username
    end
  end

  def search_books(keyword, username)
    keyword = keyword.to_s.downcase

    books_for_user(username).select do |book|
      book.title.downcase.include?(keyword) ||
        book.author.downcase.include?(keyword) ||
        book.genre.downcase.include?(keyword)
    end
  end

  def delete_user_book(index, username)
    user_books = books_for_user(username)
    book_to_delete = user_books[index]

    return false unless book_to_delete

    @books.delete(book_to_delete)
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