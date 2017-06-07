# reservation keeper

require 'sqlite3'

# db = SQLite3::Database.new("reservation.db")
db = SQLite3::Database.new("reservations.db")

create_table_cmd = <<-SQL
	CREATE TABLE login(
		id INTEGER PRIMARY KEY,
		username VARCHAR(255),
		password VARCHAR(255)
	)

	# CREATE TABLE hotel(
	# 	id INTEGER PRIMARY KEY,
	# 	hotel_name VARCHAR(255),
	# 	check_in DATE,
	# 	check_out DATE
	# )	

	# CREATE TABLE flight(
	# 	id INTEGER PRIMARY KEY,
	# 	flight_date DATE,
	# 	origin_airport VARCHAR(255),
	# 	departure_time TIME,
	# 	destination_airport VARCHAR(255),
	# 	arrival_time TIME
	# )

SQL

# db.execute(create_table_cmd)

# ask user if they are new
# if new
# 	then create a new username
# 	do check that it is not taken
# else
# 	sign in 

# make sure that username = password


# user input their travel information


# def add_something
# 	puts "Would you like to add a flight or hotel reservation?"
# 	response = gets.chomp
# 	if response == "flight"
# 		add_flight_prompt
# 	elsif response == "hotel"
# 		add_hotel_prompt
# 	else
# 		puts "I'm sorry. I did not understand that."
# 		add_something
# 	end
# end

# def add_flight(flight_date, origin_airport, departure_time, destination_airport, arrival_time)
# 	puts "On #{flight_date}, you will be flying from #{origin_airport} at #{departure_time} to #{destination_airport} and arrive #{arrival_time}."
# 	confirmation
# end

# def add_flight_prompt

# 	puts "Please enter the date of your flight:"
# 	flight_date = gets.chomp

# 	puts "Please enter your origin airport (ie AUS):"
# 	origin_airport = gets.chomp

# 	puts "Please enter your destination airport (ie AUS):"
# 	destination_airport = gets.chomp

# 	puts "Please enter the time of departure (ie 13:30):"
# 	departure_time = gets.chomp

# 	puts "Please enter the time of arrival (ie 13:30):"
# 	arrival_time = gets.chomp

# 	add_flight(flight_date, origin_airport, departure_time, destination_airport, arrival_time)

# end

# def add_hotel(hotel_name, check_in, check_out)
# 	if check_in.round(0) == check_out.round(0)
# 		nights_stayed = ((check_out - check_in)*100).round(0)
# 	end
# 	puts "You will be staying at #{hotel_name} for #{nights_stayed} nights."
# 	confirmation
# end

# def add_hotel_prompt
# 	puts "Please enter your hotel name:"
# 	hotel_name = gets.chomp

# 	puts "Please enter your check-in date: (ie 6.24)"
# 	check_in = gets.chomp.to_f

# 	puts "Please enter your check-out date: (ie 6.24)"
# 	check_out = gets.chomp.to_f

# 	add_hotel(hotel_name, check_in, check_out)
# end

# def confirmation
# 	puts "Is this information correct? y/n"
# 	response = gets.chomp

# 	if response == "y"
# 		puts "great"
# 		additions
# 	else
# 		puts "boo"
# 	# call modify method here
# 	end
# end

# def additions
# 	puts "Did you want to add or modify any additional reservations? y/n"
# 	response = gets.chomp

# 	if response == "y"
# 		add_something
# 	elsif response == "n"
# 		# print a summary of database table
# 		puts "Here is a summary of your reservations: "
# 	else
# 		puts "I'm sorry. I did not understand that."
# 		additions
# end

# add_something





# store information is stored on a database
# order by date

# special features
# notice that a flight is missing if there is no flight back to destination


