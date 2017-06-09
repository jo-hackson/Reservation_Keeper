# assumption: that all reservations are for 2017
# assumption: that password entered is correct
# assumption: all input is correctly formatted


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

def date_converter(user_input)
	user_input = user_input.split("")
	month = user_input[0].to_i
	month = Date::MONTHNAMES[month]
	day = user_input[2]
	full_date = month + " " + day
	return full_date
end

def add_flight_reservation_to_db(db, details)
	db.execute("INSERT INTO flights (flight_date, origin_airport, destination_airport, owner) 
		VALUES (?, ?, ?, ?)", [details[:flight_date], details[:origin_airport], details[:destination_airport], details[:username]])
end

def add_flight_details
	details = {}

	puts "What is the date of your flight? (ie 4/5)"
	flight_date = gets.chomp
	details[:flight_date] = date_converter(flight_date)

	puts "What is the airport you are flying from? (ie BOS)"
	origin_airport = gets.chomp.upcase!
	details[:origin_airport] = origin_airport

	puts "What is the airport you are flying to? (ie AUS)"
	destination_airport = gets.chomp.upcase!
	details[:destination_airport] = destination_airport

	details
end

def add_hotel_reservation_to_db(db, details)
	db.execute("INSERT INTO hotels (hotel_name, check_in, check_out, owner) VALUES (?, ?, ?, ?)", [details[:hotel_name], details[:check_in], details[:check_out], details[:username]])
end

def add_hotel_details
	details = {}

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

def add_reservation(db, details, reservation_type)
	case reservation_type
	when 'flight'
		details = add_flight_details
		add_flight_reservation_to_db(db, details)
		puts "On #{details[:flight_date]}, you will be flying from #{details[:origin_airport]} to #{details[:destination_airport]}."
	when 'hotel'
		details = add_hotel_details
		add_hotel_reservation_to_db(db, details)
		puts "You will be staying at the #{details[:hotel_name]} from #{details[:check_in]} to #{details[:check_out]}."
	end
end

# _____________________________________________________________________


def modify_reservation_to_db(db, details)
	db.execute("UPDATE #{details[:reservation_type] + "s"} SET #{details[:incorrect_column]}='#{details[:correct_entry]}' WHERE id=#{details[:id]}")
	# by ID
end

def column_name_converter(user_input)
	user_input = user_input.tr(" ", "_")
	return user_input
end

def modify_flight_details(details, reservation_type)

	details[:reservation_type] = reservation_type

	puts "Please type the id number of the reservation that you would like to modify: "
	id = gets.chomp
	details[:id] = id

	puts "Please select which is incorrect: \n-flight date \n-origin airport \n-destination airport"
	incorrect_column = gets.chomp
	details[:incorrect_column] = column_name_converter(incorrect_column)

	puts "Please enter the correct information: "
	correct_entry = gets.chomp

	if incorrect_column == "flight date"
		details[:correct_entry] = date_converter(correct_entry)
	elsif incorrect_column == "origin airport" || incorrect_column == "destination_airport"
		details[:correct_entry] = correct_entry.upcase!
	else
		puts "Sorry, I did not understand your input."
	end

	return details
end

def modify_hotel_details(details, reservation_type)

	details[:reservation_type] = reservation_type

	puts "Please type the id number of the reservation that you would like to <modify></modify>: "
	id = gets.chomp
	details[:id] = id

	puts "Please select which is incorrect: \n-hotel name \n-check in \n-check out"
	incorrect_column = gets.chomp
	details[:incorrect_column] = column_name_converter(incorrect_column)

	puts "Please enter the correct information: "
	correct_entry = gets.chomp

	if incorrect_column == "check in" || incorrect_column == "check out"
		details[:correct_entry] = date_converter(correct_entry)
	elsif incorrect_column == "hotel name"
		details[:correct_entry] = correct_entry.capitalize
	else
		puts "Sorry, I did not understand your input."
	end

	return details
end

def modify_reservation(db, details, reservation_type)
	# should see all reservation_type reservations
	case reservation_type
	when 'flight'
		details = modify_flight_details(details, reservation_type)
		modify_reservation_to_db(db, details)
		puts "Your flight has been modified."
		# puts "Your flight has been updated as follows: #{details[:flight_date]} from #{details[:origin_airport]} to #{details[:destination_airport]}."
	when 'hotel'
		details = modify_hotel_details(details, reservation_type)
		modify_reservation_to_db(db, details)
		puts "Your hotel has been modified."
	end
end

# _____________________________________________________________________

def delete_flight_reservation_to_db(db, username, details)
	db.execute("DELETE FROM flights #{reservation_type + "s"} WHERE id=#{details[:id]}")
end

def delete_flight_details
	details = {}

	puts "Please type the id number of the reservation that you would like to delete: "
	id = gets.chomp
	details[:id] = id

	details
end

def delete_reservation(db, details, reservation_type)
	case reservation_type
	when 'flight'
		details = get_flight_details
		add_flight_reservation_to_db(username, details)
	when 'hotel'
		details = get_hotel_details
		add_hotel_reservation_to_db(username, details)
	end
end
# _____________________________________________________________________



def view_flight_reservations(db, details)
	puts "Here are your upcoming flight reservations: "
	selected_reservation = db.execute("SELECT * FROM flights WHERE owner='#{details[:username]}'")

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

def view_hotel_reservations(db, details)
	puts "Here are you upcoming hotel reservations: "
	selected_reservation = db.execute("SELECT * FROM hotels WHERE owner='#{details[:username]}'")

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

def view_reservation(db, details, reservation_type)
	case reservation_type
	when 'flight'
		view_flight_reservations(db, details)
	when 'hotel'
		view_hotel_reservations(db, details)
	end
end


# _____________________________________________________________________

def reservation_menu(db, details)

puts "What type of reservation do you want to access? (hotel, flight, or done)"
reservation_type = gets.chomp

	if reservation_type == "done"
		# exit program
	else
		begin
			db.execute("SELECT * FROM #{reservation_type + "s"}")
		rescue
			puts "Sorry, the input you submitted does not make sense or that type of reservation does not exist."
			reservation_menu(db, details)
		ensure
		puts "Do you want to add, modify, delete, or view existing reservation?"
		modification_type = gets.chomp
			case modification_type
			when 'add'
				add_reservation(db, details, reservation_type)
			when 'modify'
				view_reservation(db, details, reservation_type)
				modify_reservation(db, details, reservation_type)
			when 'delete'
				delete_reservation(db, details, reservation_type)
			when 'view'
				view_reservation(db, details, reservation_type)
			end
			reservation_menu(db, details)
		end
	end
end

# _____________________________________________________________________

# check if username already exists
def check_old_username(db, login_information)

	login_array = db.execute("SELECT username FROM logins")

	i = 0
	while i < login_array.length do
		if login_array[i]["username"] == login_information[:username]
			matches = TRUE
			break
		end
	i += 1
	end

	if !matches 	
		puts "Sorry, that username does not exist in the database."
		new_login(db)
	else
		puts "Welcome back #{login_information[:username]}!"
	end
end

# have user input their username
def return_user(db)
	login_information = {}

	puts "Please enter your username: "
	username = gets.chomp
	login_information[:username] = username

	check_old_username(db, login_information)
	login_information
end

# set a condition that if username already exists, prompt user 
def check_new_username(db, login_information)
	begin
		db.execute("INSERT INTO logins (username, password) VALUES (?, ?)", [login_information[:username], login_information[:password]])
	rescue
		puts "Sorry, pick another username, that one is taken."
		new_login(db)
	end
end

# create a new username
def new_login(db)
	login_information = {}

	puts "Please enter your desired username: "
	username = gets.chomp
	login_information[:username] = username

	puts "Please enter your password: "
	password = gets.chomp
	login_information[:password] = password

	check_new_username(db, login_information)
	login_information
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







