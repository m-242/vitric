// A simple irc library for V
module vitric

import net
import ifndev.flogs

// The main structure, that holds a complete IRC connection.
struct IRC {
	socket net.Socket // The socket that holds the connection
pub:
	nick   string = 'vitric' // Nick
	user   string = 'asmithee' // Username
	host   string // Hostname
	logger flogs.Logger // The logger, it is public to allow customization of logs.
}

// This struct holds a message.
struct Message {
pub:
	prefix  string // Informations about the message sender
	command Command // Type of the message
	params  []string // Parameters, a.k.a destinations
	content string // Content of the message
}

// This function creates a new IRC connection to given host and port.
// SSL is not taken care of for now, but adding support for it shouldn't break the API.
pub fn new(host string, port int, nick, user, hostname string) ?IRC {
	l := flogs.Logger{
		min_logging_level: .verbose
	}
	l.log('Starting up', .info)
	s := dial(host, port) or {
		l.log("Couldn't connect to $host:$port", .critical)
		panic("Couldn't connect")
	}
	l.log('Connected', .verbose)
	conn := IRC{
		socket: s
		nick: nick
		user: user
		host: hostname
		logger: l
	}
	s.send_string('NICK $nick\nUSER $nick $hostname $user :vitric\n') or {
		l.log("Couldn't identify", .critical)
		exit(1)
	}
	return conn
}

// Closes the IRC connection properly
pub fn (irc IRC) close() {
	irc.logger.log('Gracefully quitting', .info)
	irc.raw('QUIT')
	irc.socket.close() or {
		irc.logger.log('Error closing socket', .warning)
	}
}

// Sends a raw message given as a string to the server through the irc connection.
pub fn (irc IRC) raw(message string) {
	irc.socket.send_string(message) or {
		irc.logger.log("Couldn't send '$message'", .warning)
	}
}

// Reads the connection and returns a message if there is one, or a completely empty one.
pub fn (irc IRC) read_message() Message {
	s := irc.socket.read_line()
	parsed := parse_message(s) or {
		irc.logger.log("Couldn't parse message $s", .warning)
		Message{
			command: .notamessage
		}
	}
	if parsed.command != .notamessage { // we got a message, so we log it.
		irc.logger.log(s[0..s.len - 1], .verbose)
	}
	return parsed
}
