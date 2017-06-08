# reservation keeper
# assumption: that all reservations are for 2017
# assumption: that password entered is correct
# assumption: all input is correctly formatted

require 'sqlite3'
require 'date'

db = SQLite3::Database.new("reservations.db")
# db.results_as_hash = true

# database tables creation
create_logins_table = <<-SQL
	CREATE TABLE IF NOT EXISTS logins(
		username VARCHAR(255) PRIMARY KEY,
		password VARCHAR(255)
	);
SQL

create_hotels_table = <<-SQL
	CREATE TABLE IF NOT EXISTS hotels(
		id INTEGER PRIMARY KEY,
		hotel_name VARCHAR(255),
		check_in DATE,
		check_out DATE, 
		owner VARCHAR(255),
		FOREIGN KEY (owner) REFERENCES logins(username)
	);	

SQL

create_flights_table = <<-SQL
	CREATE TABLE IF NOT EXISTS flights(
		id INTEGER PRIMARY KEY,
		flight_date DATE,
		origin_airport VARCHAR(255),
		destination_airport VARCHAR(255),
		owner VARCHAR(255),
		FOREIGN KEY (owner) REFERENCES logins(username)
	);
SQL

db.execute(create_logins_table)
db.execute(create_hotels_table)
db.execute(create_flights_table)



def modify_reservation(db)
	if @reservation_type == "hotel"
		puts "Please select which is incorrect: \n-hotel name \n-check in \n-check out"
		incorrect_entry = gets.chomp
		puts "Okay, the #{incorrect_entry} is incorrect. Please enter the update: "
		update_entry = gets.chomp
		incorrect_entry = incorrect_entry.tr(" ", "_")
		db.execute("UPDATE #{@reservation_type + "s"} SET #{incorrect_entry}=\"#{update_entry}\" WHERE owner=@desired_username")
		# UPDATE rabbits SET age=4 WHERE name="Queen Bey";
		# print updated reservation
	else 
		puts "flight"
		puts "Please select which is incorrect: \n-flight date \n-origin airport \n-destination airport"
		# @incorrect_entry = gets.chomp
		# specific_modification(db)
	end
end

def confirmation(db)
	puts "Is this information correct? y/n"
	response = gets.chomp
	if response == "y"
		puts "Great!"
		# modifications(db)
	else
		modify_reservation(db)
	end
	print_reservations(db)
end

def date_converter(user_input)
	user_input = user_input.split(" ")
	month = user_input[0].to_i
	month = Date::MONTHNAMES[month]
	day = user_input[1]
	flight_date = month + " " + day
end

# receives arguments from add_flight_prompt method to store in database
# prints all information neatly to user
# calls confirmation method to check if information is correct
def add_flight(db, flight_date, origin_airport, destination_airport, user)
	db.execute("INSERT INTO flights (flight_date, origin_airport, destination_airport, owner) 
		VALUES (?, ?, ?, ?)", [flight_date, origin_airport, destination_airport, user])
	puts "On #{flight_date}, you will be flying from #{origin_airport} to #{destination_airport}."
	confirmation(db)
end

# method called when user wants to add flight reservation from add_reservation method
# series of questions to get information from user
# passes information to add_flight method to add information to database
def add_flight_prompt(db, user)
	puts "Please enter the date of your flight: (ie 6 24)"
	response = gets.chomp
	flight_date = date_converter(response)

	puts "Please enter 3 digit airport code of your origin airport:"
	origin_airport = gets.chomp.upcase!

	puts "Please enter 3 digit airport code of your destination airport:"
	destination_airport = gets.chomp.upcase!

	add_flight(db, flight_date, origin_airport, destination_airport, user)
end

def add_hotel(db, hotel_name, check_in, check_out, user)
	db.execute("INSERT INTO hotels (hotel_name, check_in, check_out, owner) VALUES (?, ?, ?, ?)", [hotel_name, check_in, check_out, user])
	puts "You will be staying at #{hotel_name} from #{check_in} to #{check_out}."
	confirmation(db)
end

def add_hotel_prompt(db, user)
	puts "Please enter your hotel name:"
	hotel_name = gets.chomp.capitalize

	puts "Please enter your check-in date: (ie 6 24)"
	response = gets.chomp
	check_in = date_converter(response)

	puts "Please enter your check-out date: (ie 6 24)"
	response = gets.chomp
	check_out = date_converter(response)

	add_hotel(db, hotel_name, check_in, check_out, user)
end

# prompts user to decide if they want to add a flight or hotel reservation
# will redirect to add_flight_prompt or add_hotel_prompt method accordingly
# if a bad input is received, then user is prompted and add_reservation method is a called
def add_reservation(db, user)
	puts "Would you like to handle a flight or hotel reservation? (flight or hotel)"
	@reservation_type = gets.chomp

	if @reservation_type == "flight" && @new_member == true
		add_flight_prompt(db, user)
	elsif @reservation_type == "hotel" && @new_member == true
		add_hotel_prompt(db, user)
	else
		puts "Would you like to add, modify, or view the #{@reservation_type} reservation?"
		update = gets.chomp

		if update == "modify"
		# print reservation
		modify_reservation(db)
		elsif update == "view"
			print_reservations(db, @desired_username)
		elsif @reservation_type == "flight" && update == "add"
			add_flight_prompt(db, user)
		elsif @reservation_type == "hotel" && update == "add"
			add_hotel_prompt(db, user)
		else
			puts "I'm sorry. I did not understand that."
			add_reservation(db, user)
		end
	end
end

# set a condition that if username already exists, prompt user 
def create_unpw(db, desired_username, desired_password)
	begin
		db.execute("INSERT INTO logins (username, password) VALUES (?, ?)", [desired_username, desired_password])
	rescue
		puts "Sorry, pick another username, that one is taken."
		enter_login_information(db)
	end
end

def initial_prompt(db)
puts "Is this your first time at Reservation Keeper? y/n"
response = gets.chomp

	if response == "y"
		@new_member = true
		puts "Welcome to Reservation Keeper!"
		enter_login_information(db)
	elsif response == "n"
		@new_member = false
		puts "Welcome back! Please enter your username: "
		@username_input = gets.chomp
		puts "Please enter your password: "
		password_input = gets.chomp
		add_reservation(db, @username_input)
	else
		puts "I am sorry but I do not understand what you typed."
		initial_prompt(db)
	end
end

def enter_login_information(db)
	puts "Please enter your desired username: "
	@desired_username = gets.chomp
	puts "Please enter your password: "
	desired_password = gets.chomp
	create_unpw(db, @desired_username, desired_password)
	add_reservation(db, @desired_username)
end

def modifications(db)
	print_reservations(db)

	puts "Did you want to add or modify any additional reservations? add/modify/no"
	response = gets.chomp

	if response == "add"
		add_reservation(db, username)
	elsif response == "modify"
		modify_reservation(db)
	elsif response == "no"
		puts "Then we are all done"
	else
		puts "I'm sorry. I did not understand that."
		modifications(db)
	end
end

def print_reservations(db, desired_username)
	if @reservation_type == "hotel"
		p @username_input
		p db.execute("SELECT * FROM hotels WHERE owner='@username_input'")
		# hotel = selected_reservation[0][1]
		# checkin = selected_reservation[0][2]
		# checkout = selected_reservation[0][3]
		# puts "You are staying at the #{hotel_name} from #{check_in} to #{check_out}."
	else
		db.execute("SELECT * FROM flights WHERE owner=@desired_username")
		flight_date = selected_reservation[0][1]
		origin_airport = selected_reservation[0][2]
		destination_airport = selected_reservation[0][3]
		puts "You are flying on #{flight_date} from #{origin_airport} to #{destination_airport}."
	end

end





# driver code
initial_prompt(db)

# store information is stored on a database
# order by date

# special features
# notice that a flight is missing if there is no flight back to destination
# your next reservation is:



