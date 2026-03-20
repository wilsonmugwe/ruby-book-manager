#  Ruby Book Collection Manager
A simple command-line application for managing personal book collections using Ruby.


 # Overview

The Ruby Book Collection Manager is a command-line application designed to help users organise and manage a personal collection of books. The system allows users to store, retrieve, and manage book records efficiently using a simple menu-driven interface.

 # Features

Add a new book

View all books

Search for a book (by title or author)

Delete a book

Store structured book information

 # Book Structure

Each book contains the following fields:

Required:

Title

Author

Genre

Optional:

Year

 # Description

 Technologies Used

Ruby 3.4.8

Visual Studio Code

Git & GitHub

 # How to Run the Application

Open the project folder in VS Code

Open the terminal

Run the program:

``

ruby main.rb

``


# System Design

The application follows a modular structure:

A Book component represents individual book records

A management component handles operations such as adding, searching, and deleting books

A menu-driven interface allows user interaction through the command line