// A simple irc library for V
module vitric

import datatypes
import log

// The main structure, that holds a complete IRC connection.
pub struct IRC {
mut:
	conn          &Connection
	message_queue datatypes.Queue<Message>
pub:
	nick string = 'vitric' // Nick
	user string = 'asmithee' // Username
	host string // Hostname
pub mut:
	logger log.Log // The logger, it is public to allow customization of logs.
	closed bool = true
}

// This struct holds a message.
struct Message {
pub:
	prefix  string   // Informations about the message sender
	command Command  // Type of the message
	params  []string // Parameters, a.k.a destinations
	content string   // Content of the message
}

// This function creates a new IRC connection to given host and port.
pub fn new(host string, port int, nick string, user string, hostname string) ?IRC {
	mut l := log.Log{
		level: .info
	}
	l.info('Starting client.')
	use_ssl := port == 6697 // TODO: break the API instead of relying for port?
	mut irc := IRC{
		closed: false
		conn: new_connection(host, port, use_ssl)?
		nick: nick
		user: user
		host: hostname
		logger: l
	}

	irc.conn.write_string('NICK $nick\r\nUSER $nick $hostname $user :vitric\r\n') or {
		irc.close()
		return error('Could not identify.')
	}
	return irc
}

// Closes the IRC connection properly
pub fn (mut irc IRC) close() {
	if irc.closed {
		return
	}
	irc.logger.info('Gracefully quitting...')
	irc.raw('QUIT')
	irc.conn.close() or { irc.logger.warn('error while closing connection: $err') }
	irc.logger.close()
	irc.closed = true
}

// Sends a raw message given as a string to the server through the irc connection.
pub fn (mut irc IRC) raw(message string) {
	irc.conn.write_string(message) or { irc.logger.warn("Couldn't send '$message'") }
}

// Reads the connection and returns a message if there is one, or a completely empty one.
pub fn (mut irc IRC) read_message() Message {
	if irc.closed {
		panic('irc closed')
	}

	if !irc.message_queue.is_empty() {
		return irc.message_queue.pop() or { panic('This should never happen.') }
	}

	s := irc.conn.read_string() or {
		if C.errno == 104 {
			irc.logger.error(c_error_number_str(C.errno))
			irc.close()
			// This will just panic at the next call, do it now instead.
			// Might make sense to change the API and return an error instead.
			panic('irc closed')
		}

		irc.logger.warn('error while reading messages: $err')

		return Message{
			command: .notamessage
		}
	}
	irc.logger.debug('got message: $s')

	for line in s.split('\r\n') {
		if line.len == 0 {
			continue
		}

		irc.message_queue.push(parse_message(s) or {
			irc.logger.warn("Couldn't parse message $s")
			Message{
				command: .notamessage
			}
		})
	}

	return irc.message_queue.pop() or { panic('This should never happen.') }
}
