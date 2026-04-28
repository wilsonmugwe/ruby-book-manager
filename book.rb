# Represents one book in the collection
class Book
  attr_accessor :title, :author, :genre, :year

  def initialize(title, author, genre, year)
    @title = title
    @author = author
    @genre = genre
    @year = year
  end

  def to_hash
    {
      title: @title,
      author: @author,
      genre: @genre,
      year: @year
    }
  end

  def self.from_hash(data)
    Book.new(data["title"], data["author"], data["genre"], data["year"])
  end

  def display
    "#{@title} by #{@author} | Genre: #{@genre} | Year: #{@year}"
  end
end