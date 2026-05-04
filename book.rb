# Represents one book in the collection
class Book
  attr_accessor :title, :author, :genre, :year, :owner

  def initialize(title, author, genre, year, owner)
    @title = title
    @author = author
    @genre = genre
    @year = year
    @owner = owner
  end

  def to_hash
    {
      title: @title,
      author: @author,
      genre: @genre,
      year: @year,
      owner: @owner
    }
  end

  def self.from_hash(data)
    Book.new(
      data["title"],
      data["author"],
      data["genre"],
      data["year"],
      data["owner"]
    )
  end

  def display
    "#{@title} by #{@author} | Genre: #{@genre} | Year: #{@year} | Owner: #{@owner}"
  end
end