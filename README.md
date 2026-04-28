# Ruby Book Collection Manager

A command-line application for managing personal book collections using Ruby.


## Overview

The Ruby Book Collection Manager is a simple CLI application that allows users to organise and manage a personal collection of books. The system provides functionality to store, retrieve, and manage book records through a structured menu-driven interface.



## Features

- Add a new book  
- View all books  
- Search for a book (by title or author)  
- Delete a book  
- Store structured book information  



## Book Structure

Each book record contains the following fields:

### Required
- Title  
- Author  
- Genre  

### Optional
- Year  
- Description  



## Technologies Used

- Ruby 3.4.8  
- Visual Studio Code  
- Git and GitHub  



## How to Run

1. Open the project folder in Visual Studio Code  
2. Open the integrated terminal  
3. Run the program:

```bash
ruby main.rb

```
# System Design

The application follows a modular design:

A Book component represents individual book records

A BookManager handles operations such as adding, searching, viewing, and deleting books

A menu-driven interface allows user interaction via the command line


# Repository

https://github.com/wilsonmugwe/ruby-book-manager