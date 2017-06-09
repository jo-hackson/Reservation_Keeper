# # reservation keeper
# # assumption: that all reservations are for 2017
# # assumption: that password entered is correct
# # assumption: all input is correctly formatted

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




def add_reservation(username, reservation_type)
	case reservation_type
	when 'flight'
		details = get_flight_details
		add_flight_reservation_to_db(username, details)
	when 'hotel'
		details = get_hotel_details
		add_hotel_reservation_to_db(username, details)
	end
end

def add_flight_reservation_to_db(username, details)
	db.execute("INSERT INTO flights (details[:flight_date], details[:origin_airport], details[:destination_airport], owner) 
		VALUES (?, ?, ?, ?)", [flight_date, origin_airport, destination_airport, user])
end

def get_flight_details
	details = {}

	puts "What is the date of your flight?"
	flight_date = gets.chomp
	details[:flight_date] = flight_date

	puts "What is the airport you are flying from? (ie BOS)"
	origin_airport = gets.chomp
	details[:airline] = origin_airport

	puts "What is the airport you are flying to? (ie AUS)"
	destination_airport = gets.chomp
	details[:destination_airport] = destination_airport

	details
end

def add_hotel_reservation_to_db(username, details)
	db.execute("INSERT INTO flights (details[:hotel_name], details[:check_in], details[:check_out], owner) VALUES (?, ?, ?, ?)", [hotel_name, check_in, check_out, user])
end

def get_hotel_details
	details = {}

	puts "What is the name of your hotel?"
	hotel_name = gets.chomp
	details[:hotel_name] = hotel_name

	puts "When will you be checking in?"
	check_in = gets.chomp
	details[:check_in ] = check_in 

	puts "When will you be checking out?"
	check_our = gets.chomp
	details[:check_out] = check_out

	details
end

# _____________________________________________________________________

def modify_reservation(username, reservation_type)
	case reservation_type
	when 'flight'
		details = modify_flight_details
		modify_reservation(username, details, reservation_type)
	when 'hotel'
		details = modify_hotel_details
		modify_reservation(username, details)
	end
end

def modify_reservation_to_db(username, details, reservation_type)
	db.execute("UPDATE #{reservation_type + "s"} SET #{details[:incorrect_entry]}=#{details[:update_entry]} WHERE owner=@username_input")
end

def modify_flight_details
	details = {}

	puts "Please select which is incorrect: \n-hotel name \n-check in \n-check out"
	incorrect_entry = gets.chomp
	incorrect_entry = incorrect_entry.tr(" ", "_")
	details[:incorrect_entry] = incorrect_entry

	puts "Please enter the correct information: "
	correct_entry = gets.chomp
	details[:correct_entry] = correct_entry

	details
end

def get_hotel_details
	details = {}

	puts "What is the name of your hotel?"
	hotel_name = gets.chomp
	details[:hotel_name] = hotel_name

	puts "When will you be checking in?"
	check_in = gets.chomp
	details[:check_in ] = check_in 

	puts "When will you be checking out?"
	check_our = gets.chomp
	details[:check_our] = check_our

	details
end



# _____________________________________________________________________


def delete_reservation(username, reservation_type)
	case reservation_type
	when 'flight'
		details = get_flight_details
		add_flight_reservation_to_db(username, details)
	when 'hotel'
		details = get_hotel_details
		add_hotel_reservation_to_db(username, details)
	end
end

def delete_flight_reservation_to_db(username, details)
	db.execute("DELETE FROM flights #{reservation_type + "s"} WHERE id=#{details[:id]}")
end

def delete_flight_details
	details = {}

	puts "Please type the id number of the reservation that you would like to delete: "
	id = gets.chomp
	details[:id] = id

	details
end
# _____________________________________________________________________



def view_reservation(username, reservation_type)
	case reservation_type
	when 'flight'
		details = modify_flight_details
		view_hotel_reservations
	when 'hotel'
		details = modify_hotel_details
		modify_reservation(username, details)
	end
end

def view_flight_reservations
	puts "Here are your upcoming flight reservations: "
	selected_reservation = db.execute("SELECT * FROM flights WHERE owner='#{@username_input}'")

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

def view_hotel_reservations
	puts "Here are you upcoming hotel reservations: "
	selected_reservation = db.execute("SELECT * FROM hotels WHERE owner='#{@username_input}'")

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
		# next method
	when 'n'
		details = return_user(db)
		# modify_reservation(username, details)
	end
end


puts "Is this your first time at Reservation Keeper? (y/n)"
first_time_inquiry = gets.chomp
creating_login(db, first_time_inquiry)

puts "What type of reservation are you using?"
reservation_type = gets.chomp

puts "Do you want to add, modify, delete, or view existing reservation?"
modification_type = gets.chomp

case modification_type
when 'add'
	add_reservation(username, reservation_type)
when 'modify'
	modify_reservation(username, reservation_type)
when 'delete'
	delete_reservation(username, reservation_type)
when 'view'
	view_reservation(username, reservation_type)
end







