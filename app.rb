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

def historical_year_value(year)
  year_text = year.to_s.strip.upcase

  if year_text.include?("BC")
    -year_text.to_i
  else
    year_text.to_i
  end
end

get "/" do
  redirect "/login"
end

get "/login" do
  erb :login
end

post "/login" do
  username = params[:username].to_s.strip
  password = params[:password].to_s.strip

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

get "/signup" do
  erb :signup
end

post "/signup" do
  username = params[:new_username].to_s.strip
  password = params[:new_password].to_s.strip

  users = load_users

  if username.empty? || password.empty?
    @error = "Username and password are required"
    erb :signup
  elsif users.any? { |stored_user| stored_user["username"] == username }
    @error = "Username already exists"
    erb :signup
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
  @books = manager.books_for_user(@username)

  erb :dashboard
end

post "/add" do
  redirect "/login" unless session[:role]

  title = params[:title].to_s.strip
  author = params[:author].to_s.strip
  genre = params[:genre].to_s.strip
  year = params[:year].to_s.strip
  owner = session[:username]

  unless title.empty? || author.empty? || genre.empty? || year.empty?
    manager.add_book(Book.new(title, author, genre, year, owner))
  end

  redirect "/dashboard"
end

post "/search" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]
  @books = manager.search_books(params[:keyword], @username)
  @message = "Search results for '#{params[:keyword]}'"

  erb :dashboard
end

post "/filter" do
  redirect "/login" unless session[:role]

  genre = params[:genre].to_s.strip

  @username = session[:username]
  @role = session[:role]

  @books = manager.books_for_user(@username).select do |book|
    book.genre.downcase == genre.downcase
  end

  @message = "Filtered by genre: #{genre}"

  erb :dashboard
end

post "/sort/title" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]

  @books = manager.books_for_user(@username).sort_by do |book|
    book.title.downcase
  end

  @message = "Books sorted by title"

  erb :dashboard
end

post "/sort/year" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]

  @books = manager.books_for_user(@username).sort_by do |book|
    historical_year_value(book.year)
  end

  @message = "Books sorted by year"

  erb :dashboard
end

post "/delete/:index" do
  redirect "/login" unless session[:role]

  username = session[:username]
  manager.delete_user_book(params[:index].to_i, username)

  redirect "/dashboard"
end

get "/logout" do
  session.clear
  redirect "/login"
end

get "/forgot" do
  erb :forgot
end

post "/forgot" do
  username = params[:username].to_s.strip
  new_password = params[:new_password].to_s.strip
  confirm_password = params[:confirm_password].to_s.strip

  users = load_users

  user = users.find do |stored_user|
    stored_user["username"] == username
  end

  if username.empty? || new_password.empty? || confirm_password.empty?
    @error = "All fields are required"
    erb :forgot
  elsif user.nil?
    @error = "Username not found"
    erb :forgot
  elsif new_password != confirm_password
    @error = "Passwords do not match"
    erb :forgot
  else
    user["password"] = new_password
    save_users(users)

    @success = "Password reset successfully. You can now sign in."
    erb :login
  end
end