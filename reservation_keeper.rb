# reservation keeper

require 'sqlite3'

db = SQLite3::Database.new("reservations.db")
db.results_as_hash = true

# database tables creation
create_logins_table = <<-SQL
	CREATE TABLE IF NOT EXISTS logins(
		id INTEGER PRIMARY KEY,
		username VARCHAR(255),
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
		departure_time TIME,
		destination_airport VARCHAR(255),
		arrival_time TIME
	);
SQL

db.execute(create_logins_table)
db.execute(create_hotels_table)
db.execute(create_flights_table)


def create_unpw(db, desired_username, desired_password)
	db.execute("INSERT INTO logins (username, password) VALUES (?, ?)", [desired_username, desired_password])
end

# set a condition that if username already exists, prompt user 
def check_username(db, desired_username)

	p db.execute("SELECT * FROM logins")["username"]

	i = 0
	until i > db.execute("SELECT MAX(id) FROM logins").join.to_i do
	db.execute("SELECT * FROM logins").each { |username| 
		if username == desired_username
			puts "match"
		else
			"no match"
		end
	}
	i += 1

	end

end

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
		# enter your username and password
		puts "Welcome back! Please enter your username: "
		username_input = gets.chomp
		puts "Please enter your password: "
		password_input = gets.chomp
	else
		puts "I am sorry but I do not understand what you typed."
		initial_prompt(db)
	end
end


# initial_prompt(db)




def create_hotel(db, desired_username, desired_password)
	db.execute("INSERT INTO logins (username, password) VALUES (?, ?)", [desired_username, desired_password])
end

def add_hotel(hotel_name, check_in, check_out)
	if check_in.round(0) == check_out.round(0)
		nights_stayed = ((check_out - check_in)*100).round(0)
	end
	puts "You will be staying at #{hotel_name} for #{nights_stayed} nights."
	confirmation
end

def add_hotel_prompt
	puts "Please enter your hotel name:"
	hotel_name = gets.chomp

	puts "Please enter your check-in date: (ie 6.24)"
	check_in = gets.chomp.to_f

	puts "Please enter your check-out date: (ie 6.24)"
	check_out = gets.chomp.to_f

	add_hotel(hotel_name, check_in, check_out)
end

def add_something
	puts "Would you like to add a flight or hotel reservation?"
	response = gets.chomp
	if response == "flight"
		add_flight_prompt
	elsif response == "hotel"
		add_hotel_prompt
	else
		puts "I'm sorry. I did not understand that."
		add_something
	end
end

def add_flight(db, flight_date, origin_airport, departure_time, destination_airport, arrival_time)
	db.execute("INSERT INTO flights (flight_date, origin_airport, departure_time, destination_airport, arrival_time) 
		VALUES (?, ?, ?, ?, ?)", [flight_date, origin_airport, departure_time, destination_airport, arrival_time])
	puts "On #{flight_date}, you will be flying from #{origin_airport} at #{departure_time} to #{destination_airport} and arrive #{arrival_time}."
	# confirmation
end

def add_flight_prompt(db)

	puts "Please enter the date of your flight: (ie June 24)"
	flight_date = gets.chomp

	puts "Please enter your origin airport (ie AUS):"
	origin_airport = gets.chomp

	puts "Please enter your destination airport (ie AUS):"
	destination_airport = gets.chomp

	puts "Please enter the time of departure (ie 13:30):"
	departure_time = gets.chomp

	puts "Please enter the time of arrival (ie 13:30):"
	arrival_time = gets.chomp

	add_flight(db, flight_date, origin_airport, destination_airport, departure_time,arrival_time)

end

add_flight_prompt(db)



def confirmation
	puts "Is this information correct? y/n"
	response = gets.chomp

	if response == "y"
		puts "great"
		additions
	else
		puts "boo"
	# call modify method here
	end
end

def additions
	puts "Did you want to add or modify any additional reservations? y/n"
	response = gets.chomp

	if response == "y"
		add_something
	elsif response == "n"
		# print a summary of database table
		puts "Here is a summary of your reservations: "
	else
		puts "I'm sorry. I did not understand that."
		additions
	end
end

# add_something





# store information is stored on a database
# order by date

# special features
# notice that a flight is missing if there is no flight back to destination


