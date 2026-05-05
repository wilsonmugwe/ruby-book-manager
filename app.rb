# ===============================================================
# File Name: app.rb
# Purpose:
# This file is the main controller of the Book Collection Manager
# web application. It uses the Sinatra framework to define routes,
# manage sessions, authenticate users, process book actions, and
# render the correct views.
# ===============================================================

require "sinatra"              # Lightweight Ruby web framework
require "json"                 # Ruby library for reading/writing JSON files
require_relative "book"        # Imports the Book model class
require_relative "book_manager" # Imports the BookManager processing class

# Enables session support so user login data can be stored temporarily
enable :sessions

# Creates one BookManager object used throughout the application
manager = BookManager.new

# Constant storing the user account file name
USERS_FILE = "users.json"

# ---------------------------------------------------------------
# Method Name: load_users
# Purpose:
# Loads registered users from users.json.
# If the file does not exist, a default administrator account is
# created automatically so the system can be accessed initially.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Method Name: save_users
# Purpose:
# Saves the updated user list back into users.json using formatted
# JSON output. This supports persistent user account storage.
# ---------------------------------------------------------------
def save_users(users)
  File.write(USERS_FILE, JSON.pretty_generate(users))
end

# ---------------------------------------------------------------
# Method Name: historical_year_value
# Purpose:
# Converts year values into sortable integers.
# This method allows the application to correctly sort books that
# use historical year formats such as "500 BC".
# ---------------------------------------------------------------
def historical_year_value(year)
  year_text = year.to_s.strip.upcase

  if year_text.include?("BC")
    -year_text.to_i
  else
    year_text.to_i
  end
end

# ---------------------------------------------------------------
# Route: GET /
# Purpose:
# Redirects users from the root URL to the login page.
# ---------------------------------------------------------------
get "/" do
  redirect "/login"
end

# ---------------------------------------------------------------
# Route: GET /login
# Purpose:
# Displays the login page.
# ---------------------------------------------------------------
get "/login" do
  erb :login
end

# ---------------------------------------------------------------
# Route: POST /login
# Purpose:
# Processes login form submissions by checking the entered username
# and password against records stored in users.json.
# If successful, the username and role are stored in the session.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Route: GET /signup
# Purpose:
# Displays the user registration page.
# ---------------------------------------------------------------
get "/signup" do
  erb :signup
end

# ---------------------------------------------------------------
# Route: POST /signup
# Purpose:
# Creates a new standard user account after validating that the
# username and password are not empty and that the username has
# not already been registered.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Route: GET /dashboard
# Purpose:
# Displays the main dashboard after login.
# Only books owned by the currently logged-in user are loaded.
# ---------------------------------------------------------------
get "/dashboard" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]
  @books = manager.books_for_user(@username)

  erb :dashboard
end

# ---------------------------------------------------------------
# Route: POST /add
# Purpose:
# Handles the add-book form.
# The input values are cleaned, validated, converted into a Book
# object, and then passed to BookManager for storage.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Route: POST /search
# Purpose:
# Searches the logged-in user's book collection by title, author,
# or genre and displays matching results on the dashboard.
# ---------------------------------------------------------------
post "/search" do
  redirect "/login" unless session[:role]

  @username = session[:username]
  @role = session[:role]
  @books = manager.search_books(params[:keyword], @username)
  @message = "Search results for '#{params[:keyword]}'"

  erb :dashboard
end

# ---------------------------------------------------------------
# Route: POST /filter
# Purpose:
# Filters the logged-in user's book collection by genre.
# The comparison is case-insensitive to improve usability.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Route: POST /sort/title
# Purpose:
# Sorts the logged-in user's books alphabetically by title.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Route: POST /sort/year
# Purpose:
# Sorts the logged-in user's books by year.
# The historical_year_value method is used so BC dates are ordered
# correctly before AD/current era dates.
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Route: POST /delete/:index
# Purpose:
# Deletes a selected book from the logged-in user's collection
# using the index supplied from the dashboard.
# ---------------------------------------------------------------
post "/delete/:index" do
  redirect "/login" unless session[:role]

  username = session[:username]
  manager.delete_user_book(params[:index].to_i, username)

  redirect "/dashboard"
end

# ---------------------------------------------------------------
# Route: GET /logout
# Purpose:
# Clears the current session and returns the user to the login page.
# ---------------------------------------------------------------
get "/logout" do
  session.clear
  redirect "/login"
end

# ---------------------------------------------------------------
# Route: GET /forgot
# Purpose:
# Displays the password reset page.
# ---------------------------------------------------------------
get "/forgot" do
  erb :forgot
end

# ---------------------------------------------------------------
# Route: POST /forgot
# Purpose:
# Allows an existing user to reset their password after validation.
# The system checks that all fields are completed, the username
# exists, and both entered passwords match before saving changes.
# ---------------------------------------------------------------
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