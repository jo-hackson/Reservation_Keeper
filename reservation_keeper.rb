# reservation keeper

require 'sqlite3'

db = SQLite3::Database.new("reservations.db")
# db.results_as_hash = true

# database tables creation
create_logins_table = <<-SQL
	CREATE TABLE IF NOT EXISTS logins(
		username VARCHAR(255) PRIMARY KEY,
		password VARCHAR(255)
	)
SQL

create_hotels_table = <<-SQL
	CREATE TABLE IF NOT EXISTS hotels(
		id INTEGER PRIMARY KEY,
		hotel_name VARCHAR(255),
		check_in DATE,
		check_out DATE
	);	

SQL

create_flights_table = <<-SQL
	CREATE TABLE IF NOT EXISTS flights(
		id INTEGER PRIMARY KEY,
		flight_date DATE,
		origin_airport VARCHAR(255),
		destination_airport VARCHAR(255),
	);
SQL

db.execute(create_logins_table)
db.execute(create_hotels_table)
db.execute(create_flights_table)


def create_unpw(db, desired_username, desired_password)
	db.execute("INSERT INTO logins (username, password) VALUES (?, ?)", [desired_username, desired_password])
end

# set a condition that if username already exists, prompt user 
# def check_username(db, desired_username)

# 	p db.execute("SELECT * FROM logins")["username"]

# 	i = 0
# 	until i > db.execute("SELECT MAX(id) FROM logins").join.to_i do
# 	db.execute("SELECT * FROM logins").each { |username| 
# 		if username == desired_username
# 			puts "match"
# 		else
# 			"no match"
# 		end
# 	}
# 	i += 1

# 	end

# end

def initial_prompt(db)

puts "Is this your first time at Reservation Keeper? y/n"
response = gets.chomp

	if response == "y"
		puts "Welcome to Reservation Keeper! Please enter your desired username: "
		desired_username = gets.chomp
		puts "Please enter your password: "
		desired_password = gets.chomp
		create_unpw(db, desired_username, desired_password)
		check_username(db, desired_username)
	elsif response == "n"
		puts "Welcome back! Please enter your username: "
		username_input = gets.chomp
		puts "Please enter your password: "
		password_input = gets.chomp
	else
		puts "I am sorry but I do not understand what you typed."
		initial_prompt(db)
	end
end

# driver code
# initial_prompt(db)

def add_hotel(db, hotel_name, check_in, check_out)
	db.execute("INSERT INTO logins (hotel_name, check_in, check_out) VALUES (?, ?, ?)", [hotel_name, check_in, check_out])
	if check_in.round(0) == check_out.round(0)
		nights_stayed = ((check_out - check_in)*100).round(0)
	end
	puts "You will be staying at #{hotel_name} for #{nights_stayed} nights."
	# confirmation
end

def add_hotel_prompt(db)
	puts "Please enter your hotel name:"
	hotel_name = gets.chomp

	puts "Please enter your check-in date: (ie 6.24)"
	check_in = gets.chomp.to_f

	puts "Please enter your check-out date: (ie 6.24)"
	check_out = gets.chomp.to_f

	add_hotel(db, hotel_name, check_in, check_out)
end


# receives arguments from add_flight_prompt method to store in database
# prints all information neatly to user
# calls confirmation method to check if information is correct
def add_flight(db, flight_date, origin_airport, destination_airport)
	db.execute("INSERT INTO flights (flight_date, origin_airport, destination_airport) 
		VALUES (?, ?, ?, ?, ?)", [flight_date, origin_airport, destination_airport])
	puts "On #{flight_date}, you will be flying from #{origin_airport} to #{destination_airport}."
	# confirmation
end

# method called when user wants to add flight reservation from add_reservation method
# series of questions to get information from user
# passes information to add_flight method to add information to database
def add_flight_prompt(db)

	puts "Please enter the date of your flight: (ie 6 24)"
	response = gets.chomp.split(" ")
	month = response[0]
	day = response[1]
	flight_date = Time.new(2017, month, day)

	puts "Please enter 3 digit airport code of your origin airport:"
	origin_airport = gets.chomp.upcase!

	puts "Please enter 3 digit airport code of your destination airport:"
	destination_airport = gets.chomp.upcase!

	add_flight(db, flight_date, origin_airport, destination_airport)
end

# prompts user to decide if they want to add a flight or hotel reservation
# will redirect to add_flight_prompt or add_hotel_prompt method accordingly
# if a bad input is received, then user is prompted and add_reservation method is a called
def add_reservation(db)
	puts "Would you like to add a flight or hotel reservation?"
	response = gets.chomp
	if response == "flight"
		add_flight_prompt(db)
	elsif response == "hotel"
		add_hotel_prompt(db)
	else
		puts "I'm sorry. I did not understand that."
		add_reservation(db)
	end
end

def confirmation(db)
	puts "Is this information correct? y/n"
	response = gets.chomp

	if response == "y"
		puts "great"
		additions(db)
	else
		puts "boo"
		# call modify method here
	end
end

def additions(db)
	puts "Did you want to add or modify any additional reservations? y/n"
	response = gets.chomp

	if response == "y"
		add_reservation(db)
	elsif response == "n"
		# print a summary of database table
		puts "Here is a summary of your reservations: "
	else
		puts "I'm sorry. I did not understand that."
		additions(db)
	end
end

def modify_reservation(db)

end







# store information is stored on a database
# order by date

# special features
# notice that a flight is missing if there is no flight back to destination
# your next reservation is:

