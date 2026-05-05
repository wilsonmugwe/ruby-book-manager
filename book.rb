# ============================================================
# Class Name: Book
# Purpose:
# This class acts as the data model for a single book object
# within the Book Collection Manager application.
# Each Book instance stores all information related to one
# library record and provides helper methods for conversion,
# loading, and formatted display.
# ============================================================

class Book

  # attr_accessor automatically creates getter and setter methods
  # for each attribute, allowing controlled access to book data
  attr_accessor :title, :author, :genre, :year, :owner

  # ------------------------------------------------------------
  # Constructor Method: initialize
  # Purpose:
  # Creates a new Book object whenever a user adds a new record.
  # Parameters received from GUI form fields are assigned to the
  # instance variables below.
  # ------------------------------------------------------------
  def initialize(title, author, genre, year, owner)
    @title = title      # Stores the title of the book
    @author = author    # Stores the author's name
    @genre = genre      # Stores the literary category/genre
    @year = year        # Stores publication year
    @owner = owner      # Stores username of the person who added it
  end

  # ------------------------------------------------------------
  # Method Name: to_hash
  # Purpose:
  # Converts the current Book object into hash format so that
  # Ruby's JSON library can easily save the data into a file.
  # This supports persistent storage of all records.
  # ------------------------------------------------------------
  def to_hash
    {
      title: @title,
      author: @author,
      genre: @genre,
      year: @year,
      owner: @owner
    }
  end

  # ------------------------------------------------------------
  # Class Method: self.from_hash
  # Purpose:
  # Reconstructs a Book object from hash/JSON data when the
  # program loads previously saved records from books.json.
  # This allows persistent records to be converted back into
  # usable Ruby objects.
  # ------------------------------------------------------------
  def self.from_hash(data)
    Book.new(
      data["title"],
      data["author"],
      data["genre"],
      data["year"],
      data["owner"]
    )
  end

  # ------------------------------------------------------------
  # Method Name: display
  # Purpose:
  # Returns a neatly formatted string version of the book record
  # for output inside the GUI listbox and search results panel.
  # ------------------------------------------------------------
  def display
    "#{@title} by #{@author} | Genre: #{@genre} | Year: #{@year} | Owner: #{@owner}"
  end
end