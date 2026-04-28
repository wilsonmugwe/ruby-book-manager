require "sinatra"
require "json"
require_relative "book"
require_relative "book_manager"

enable :sessions

manager = BookManager.new

USERS_FILE = "users.json"

def load_users
  unless File.exist?(USERS_FILE)
    default_users = [
      {
        username: "admin",
        password: "admin123",
        role: "admin"
      }
    ]

    File.write(USERS_FILE, JSON.pretty_generate(default_users))
  end

  JSON.parse(File.read(USERS_FILE))
end

def save_users(users)
  File.write(USERS_FILE, JSON.pretty_generate(users))
end

get "/" do
  redirect "/login"
end

get "/login" do
  erb :login
end

post "/login" do
  username = params[:username].strip
  password = params[:password].strip

  users = load_users

  user = users.find do |stored_user|
    stored_user["username"] == username && stored_user["password"] == password
  end

  if user
    session[:username] = user["username"]
    session[:role] = user["role"]
    redirect "/dashboard"
  else
    @error = "Invalid username or password"
    erb :login
  end
end

post "/signup" do
  username = params[:new_username].strip
  password = params[:new_password].strip

  users = load_users

  if username.empty? || password.empty?
    @error = "Username and password are required"
    erb :login
  elsif users.any? { |stored_user| stored_user["username"] == username }
    @error = "Username already exists"
    erb :login
  else
    users << {
      username: username,
      password: password,
      role: "user"
    }

    save_users(users)

    @success = "Account created successfully. Please sign in."
    erb :login
  end
end

get "/dashboard" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]
  @books = manager.view_books
  erb :dashboard
end

post "/add" do
  redirect "/login" unless session[:role]

  title = params[:title].strip
  author = params[:author].strip
  genre = params[:genre].strip
  year = params[:year].strip

  unless title.empty? || author.empty? || genre.empty? || year.empty?
    manager.add_book(Book.new(title, author, genre, year))
  end

  redirect "/dashboard"
end

post "/search" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]
  @books = manager.search_books(params[:keyword])
  @message = "Search results for '#{params[:keyword]}'"
  erb :dashboard
end

post "/filter" do
  redirect "/login" unless session[:role]

  genre = params[:genre].strip

  @username = session[:username]
  @role = session[:role]
  @books = manager.view_books.select do |book|
    book.genre.downcase == genre.downcase
  end
  @message = "Filtered by genre: #{genre}"
  erb :dashboard
end

post "/sort/title" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]
  @books = manager.view_books.sort_by { |book| book.title.downcase }
  @message = "Books sorted by title"
  erb :dashboard
end

post "/sort/year" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]
  @books = manager.view_books.sort_by { |book| book.year.to_i }
  @message = "Books sorted by year"
  erb :dashboard
end

post "/delete/:index" do
  redirect "/login" unless session[:role]

  if session[:role] == "admin"
    manager.delete_book(params[:index].to_i)
  end

  redirect "/dashboard"
end

get "/logout" do
  session.clear
  redirect "/login"
end

get "/signup" do
  erb :signup
end

get "/forgot" do
  erb :forgot
end