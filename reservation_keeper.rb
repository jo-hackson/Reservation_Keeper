# assumption: that all reservations are for 2017
# assumption: that password entered is correct
# assumption: all input is correctly formatted
# assumption: that user will select an input presented to them
# when users login, then view, information will not show up


require 'sqlite3'
require 'date'

db = SQLite3::Database.new("reservations.db")
db.results_as_hash = true

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


# ____________________________________________________________________

def check_id(db, details)

	i = 0
	id_exists = []
	until i >= details[:selected_reservation].length
	  if details[:selected_reservation][i]["id"] != details[:id].to_i
	    id_exists << "false"
	  end
	  i += 1
	end

	if id_exists.include?("false")
	  puts "Sorry, the id you input refers to a reservation is not in your name."
	  modify_flight_details(db, details)
	end
end

def print_updated_reservation(db, details)
	case details[:reservation_type]
	when 'flight'
		if details[:flight_date] == nil 
			puts "Your request to #{details[:modification_type]} your flight reservation is complete."
		else
			puts "Your request to #{details[:modification_type]} your flight reservation on #{details[:flight_date]} from #{details[:origin_airport]} to #{details[:destination_airport]} is complete."
		end
	when 'hotel'
		if details[:hotel_name] == nil
			puts "Your request to #{details[:modification_type]} your hotel reservation is complete."
		else
			puts "Your request to #{details[:modification_type]} your hotel reservation at #{details[:hotel_name]} from #{details[:check_in]} to #{details[:check_out]} is complete."
		end
	end	
end

def date_converter(user_input)
	user_input = user_input.split("/")
	month = user_input[0].to_i
	month = Date::MONTHNAMES[month]
	day = user_input[1]
	full_date = month + " " + day
	return full_date
end

def add_flight_reservation_to_db(db, details)
	db.execute("INSERT INTO flights (flight_date, origin_airport, destination_airport, owner) 
		VALUES (?, ?, ?, ?)", [details[:flight_date], details[:origin_airport], details[:destination_airport], details[:username]])
end

def add_flight_details(details)
	puts "What is the date of your flight? (ie 4/5)"
	flight_date = gets.chomp
	details[:flight_date] = date_converter(flight_date)

	puts "What is the airport you are flying from? (ie BOS)"
	origin_airport = gets.chomp.upcase!
	details[:origin_airport] = origin_airport

	puts "What is the airport you are flying to? (ie AUS)"
	destination_airport = gets.chomp.upcase!
	details[:destination_airport] = destination_airport
	puts "On #{details[:flight_date]}, you will be flying from #{details[:origin_airport]} to #{details[:destination_airport]}."
	details
end

def add_hotel_reservation_to_db(db, details)
	db.execute("INSERT INTO hotels (hotel_name, check_in, check_out, owner) VALUES (?, ?, ?, ?)", [details[:hotel_name], details[:check_in], details[:check_out], details[:username]])
end

def add_hotel_details(details)
	puts "What is the name of your hotel?"
	hotel_name = gets.chomp.capitalize
	details[:hotel_name] = hotel_name

	puts "When will you be checking in? (ie 2/5)"
	check_in = gets.chomp
	details[:check_in] = date_converter(check_in)

	puts "When will you be checking out? (ie 2/6)"
	check_out = gets.chomp
	details[:check_out] = date_converter(check_out)
	details
end

def add_reservation(db, details)
	case details[:reservation_type]
	when 'flight'
		details = add_flight_details(details)
		add_flight_reservation_to_db(db, details)
	when 'hotel'
		details = add_hotel_details(details)
		add_hotel_reservation_to_db(db, details)
	end
	print_updated_reservation(db, details)
end

# _____________________________________________________________________


def standardize_input(details)
	if details[:incorrect_column] == "flight_date" || details[:incorrect_column] == "check_in" || details[:incorrect_column] == "check_out"
		details[:correct_entry] = date_converter(details[:correct_entry])
	elsif details[:incorrect_column] == "origin_airport" || details[:incorrect_column] == "destination_airport"
		details[:correct_entry] = details[:correct_entry].upcase!
	elsif details[:incorrect_column] == "hotel_name"
		details[:correct_entry] = details[:correct_entry].capitalize
	else
		puts "Sorry, I did not understand your input."
	end
	return details
end

def column_name_converter(user_input)
	user_input = user_input.tr(" ", "_")
	return user_input
end

def modify_reservation_to_db(db, details)
	db.execute("UPDATE #{details[:reservation_types]} SET #{details[:incorrect_column]}='#{details[:correct_entry]}' WHERE id=#{details[:id]}")
end

def modify_flight_details(db, details)
	puts "Please type the id number of the reservation that you would like to modify: "
	id = gets.chomp
	details[:id] = id
	check_id(db, details)

	puts "Please select which is incorrect: \n-flight date \n-origin airport \n-destination airport"
	incorrect_column = gets.chomp
	details[:incorrect_column] = column_name_converter(incorrect_column)

	puts "Please enter the correct information: "
	correct_entry = gets.chomp
	details[:correct_entry] = correct_entry
	standardize_input(details)
	return details
end

def modify_hotel_details(db, details)
	puts "Please type the id number of the reservation that you would like to modify: "
	id = gets.chomp
	details[:id] = id
	check_id(db, details)

	puts "Please select which is incorrect: \n-hotel name \n-check in \n-check out"
	incorrect_column = gets.chomp
	details[:incorrect_column] = column_name_converter(incorrect_column)

	puts "Please enter the correct information: "
	correct_entry = gets.chomp
	details[:correct_entry] = correct_entry
	standardize_input(details)
	return details
end

def modify_reservation(db, details)
	case details[:reservation_type]
	when 'flight'
		details = modify_flight_details(db, details)
		modify_reservation_to_db(db, details)
	when 'hotel'
		details = modify_hotel_details(db, details)
		modify_reservation_to_db(db, details)
	end
	print_updated_reservation(db, details)
end

# _____________________________________________________________________

def delete_reservation_from_db(db, details)
	db.execute("DELETE FROM #{details[:reservation_types]} WHERE id=#{details[:id]}")
end

def delete_details(db, details)
	puts "Please type the id number of the reservation that you would like to delete: "
	id = gets.chomp
	details[:id] = id
	check_id(db, details)
	return details
end

def delete_reservation(db, details)
 	details = delete_details(db, details)
	delete_reservation_from_db(db, details)
	print_updated_reservation(db, details)
end
# _____________________________________________________________________

# find length of hash and use that number
def print_number_reservations(db, details, selected_reservation)
	puts "You have #{selected_reservation.length} #{details[:reservation_type]} reservation(s) to #{details[:modification_type]}."
end

def print_flight_reservations(db, details, selected_reservation)
	i = 0
	while i < selected_reservation.length do
		id = selected_reservation[i][0]
		flightdate = selected_reservation[i][1]
		originairport = selected_reservation[i][2]
		destinationairport = selected_reservation[i][3]
		puts "[#{id}] #{flightdate} flying from #{originairport} to #{destinationairport}."
	i +=1
	end
end

def print_hotel_reservations(db, details, selected_reservation)
	i = 0
	while i < selected_reservation.length do
		id = selected_reservation[i][0]
		hotel = selected_reservation[i][1]
		checkin = selected_reservation[i][2]
		checkout = selected_reservation[i][3]
		puts "[#{id}] Staying at #{hotel} from #{checkin} to #{checkout}."
	i +=1
	end
end

def view_reservations(db, details)
	puts "Here are your upcoming #{details[:reservation_type]} reservations: "
	selected_reservation = db.execute("SELECT * FROM #{details[:reservation_types]} WHERE owner='#{details[:username]}'")
end

def view_reservation(db, details)
	selected_reservation = view_reservations(db, details)
	details[:selected_reservation] = selected_reservation
	case details[:reservation_type]
	when 'flight'
		print_flight_reservations(db, details, selected_reservation)
	when 'hotel'
		print_hotel_reservations(db, details, selected_reservation)
	end
	print_number_reservations(db, details, selected_reservation)
end

def redirect_path(db, details)
	if details[:selected_reservation].length == 0
		reservation_menu(db, details)
	elsif details[:modification_type] == "modify"
		modify_reservation(db, details)
	elsif details[:modification_type] == "delete"
		delete_reservation(db, details)
	else details[:modification_type] == "view"
		reservation_menu(db, details)
	end
end

# _____________________________________________________________________

def reservation_menu(db, details)

	puts "What type of reservation do you want to access? (hotel, flight, or done)"
	reservation_type = gets.chomp

	if reservation_type == "done"
	else
		begin
			db.execute("SELECT * FROM #{reservation_type + "s"}")
		rescue
			puts "Sorry, the input you submitted does not make sense or that type of reservation does not exist."
			reservation_menu(db, details)
		ensure
		puts "Do you want to add, modify, delete, or view existing reservation?"
		modification_type = gets.chomp
		details[:modification_type] = modification_type
		details[:reservation_type] = reservation_type
		details[:reservation_types] = reservation_type + "s"
			case modification_type
			when 'add'
				add_reservation(db, details)
			when 'modify', 'delete', 'view'
				view_reservation(db, details)
				redirect_path(db, details)
			else
				"Sorry, your input is incomprehensible."
			end
			reservation_menu(db, details)
		end
	end
end

# _____________________________________________________________________


def password_checker(db, details)

	puts "Please enter your password."
	password = gets.chomp
	details[:password] = password

	if (db.execute("SELECT * FROM logins WHERE username='#{details[:username]}'"))[0]["password"] != details[:password]
		puts "Sorry, your username and password do not match."
		return_user(db)
	end
end

# check if username already exists
def check_old_username(db, details)

	login_array = db.execute("SELECT username FROM logins")

	i = 0
	while i < login_array.length do
		if login_array[i]["username"] == details[:username]
			matches = TRUE
			break
		end
	i += 1
	end

	password_checker(db, details)

	if !matches 	
		puts "Sorry, that username does not exist in the database."
		new_login(db)
	else
		puts "Welcome back #{details[:username]}!"
	end
end

# have user input their username
def return_user(db)
	details = {}

	puts "Please enter your username: "
	username = gets.chomp
	details[:username] = username

	check_old_username(db, details)
	details
end

# set a condition that if username already exists, prompt user 
def check_new_username(db, details)
	begin
		db.execute("INSERT INTO logins (username, password) VALUES (?, ?)", [details[:username], details[:password]])
	rescue
		puts "Sorry, pick another username, that one is taken."
		new_login(db)
	end
end

# create a new username
def new_login(db)
	details = {}

	puts "Please enter your desired username: "
	username = gets.chomp
	details[:username] = username

	puts "Please enter your password: "
	password = gets.chomp
	details[:password] = password

	check_new_username(db, details)
	return details
end

def creating_login(db, first_time_inquiry)
	case first_time_inquiry
	when 'y'
		puts "Welcome to Reservation Keeper!"	
		details = new_login(db)
	when 'n'
		details = return_user(db)
	end
	reservation_menu(db, details)
end

puts "Is this your first time at Reservation Keeper? (y/n)"
first_time_inquiry = gets.chomp
creating_login(db, first_time_inquiry)







