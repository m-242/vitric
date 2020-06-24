module vitric

// Contains everything related to parsing of messages
// Parses a raw message into an easier to use Message structure
fn parse_message(raw string) ?Message {
	if raw.len == 0 {
		return Message{
			command: .notamessage
		}
	}
	command, has_prefix := ident_command(raw)
	if command == .notamessage {
		return Message{
			command: .notamessage
		}
	}
	if !has_prefix {
		return parse_no_prefix(raw, command)
	}
	if has_prefix {
		return parse_prefix(raw, command)
	}
}

// COMMAND specific parsing functions
// Parsing messages that don't have a prefix
fn parse_no_prefix(m string, c Command) ?Message {
	ms := m.split_nth(' ', 3)
	if ms.len == 2 { // Command param
		return Message{
			command: c
			params: ms[1].split(',')
		}
	}
	if ms.len == 3 {
		return Message{
			command: c
			params: ms[1].split(',')
			content: ms[2].replace_once(':', '').replace_once('\n', '')
		}
	}
	return error("Couldn't parse message '$m'")
}

fn parse_prefix(raw string, c Command) ?Message {
	s := raw.split_nth(' ', 2)
	m := parse_no_prefix(s[1], c) or {
		return Message{
			command: .notamessage
		}
	}
	return Message{
		prefix: s[0][1..s[0].len]
		command: m.command
		params: m.params
		content: m.content
	}
}

fn ident_command(c string) (Command, bool) {
	if c.contains('ADMIN') {
		return Command.admin, true
	}
	if c.contains('AWAY') {
		return Command.away, true
	}
	if c.contains('CNOTICE') {
		return Command.cnotice, true
	}
	if c.contains('CPRIVMSG') {
		return Command.cprivmsg, true
	}
	if c.contains('CONNECT') {
		return Command.connect, true
	}
	if c.contains('DIE') {
		return Command.die, true
	}
	if c.contains('ENCAP') {
		return Command.encap, true
	}
	if c.contains('ERROR') {
		return Command.error, true
	}
	if c.contains('HELP') {
		return Command.help, true
	}
	if c.contains('INFO') {
		return Command.info, true
	}
	if c.contains('INVITE') {
		return Command.invite, true
	}
	if c.contains('ISON') {
		return Command.ison, true
	}
	if c.contains('JOIN') {
		return Command.join, true
	}
	if c.contains('KICK') {
		return Command.kick, true
	}
	if c.contains('KILL') {
		return Command.kill, true
	}
	if c.contains('KNOCK') {
		return Command.knock, true
	}
	if c.contains('LINKS') {
		return Command.links, true
	}
	if c.contains('LIST') {
		return Command.list, true
	}
	if c.contains('LUSERS') {
		return Command.lusers, true
	}
	if c.contains('MODE') {
		return Command.mode, true
	}
	if c.contains('MOTD') || c.contains('372') {
		return Command.motd, true
	}
	if c.contains('NAMES') {
		return Command.names, true
	}
	if c.contains('NAMESX') {
		return Command.namesx, true
	}
	if c.contains('NICK') {
		return Command.nick, true
	}
	if c.contains('NOTICE') {
		return Command.notice, true
	}
	if c.contains('OPER') {
		return Command.oper, true
	}
	if c.contains('PART') {
		return Command.part, true
	}
	if c.contains('PASS') {
		return Command.pass, true
	}
	if c.contains('PING') {
		return Command.ping, false
	}
	if c.contains('PONG') {
		return Command.pong, true
	}
	if c.contains('PRIVMSG') {
		return Command.privmsg, true
	}
	if c.contains('QUIT') {
		return Command.quit, true
	}
	if c.contains('REHASH') {
		return Command.rehash, true
	}
	if c.contains('RESTART') {
		return Command.restart, true
	}
	if c.contains('RULES') {
		return Command.rules, true
	}
	if c.contains('SERVER') {
		return Command.server, true
	}
	if c.contains('SERVICE') {
		return Command.service, true
	}
	if c.contains('SERVLIST') {
		return Command.servlist, true
	}
	if c.contains('SQUERY') {
		return Command.squery, true
	}
	if c.contains('SQUIT') {
		return Command.squit, true
	}
	if c.contains('SETNAME') {
		return Command.setname, true
	}
	if c.contains('SILENCE') {
		return Command.silence, true
	}
	if c.contains('STATS') {
		return Command.stats, true
	}
	if c.contains('SUMMON') {
		return Command.summon, true
	}
	if c.contains('TIME') {
		return Command.time, true
	}
	if c.contains('TOPIC') {
		return Command.topic, true
	}
	if c.contains('TRACE') {
		return Command.trace, true
	}
	if c.contains('UHNAMES') {
		return Command.uhnames, true
	}
	if c.contains('USER') {
		return Command.user, true
	}
	if c.contains('USERHOST') {
		return Command.userhost, true
	}
	if c.contains('USERIP') {
		return Command.userip, true
	}
	if c.contains('USERS') {
		return Command.users, true
	}
	if c.contains('VERSION') {
		return Command.version, true
	}
	if c.contains('WALLOPS') {
		return Command.wallops, true
	}
	if c.contains('WATCH') {
		return Command.watch, true
	}
	if c.contains('WHO') {
		return Command.who, true
	}
	if c.contains('WHOIS') {
		return Command.whois, true
	}
	if c.contains('WHOWAS') {
		return Command.whowas, true
	}
	return Command.notamessage, true
}

// see rfc1459 and https://en.wikipedia.org/wiki/list_of_internet_relay_chat_commands
enum Command {
	notamessage
	admin
	away
	cnotice
	cprivmsg
	connect
	die
	encap
	error
	help
	info
	invite
	ison
	join
	kick
	kill
	knock
	links
	list
	lusers
	mode
	motd
	names
	namesx
	nick
	notice
	oper
	part
	pass
	ping
	pong
	privmsg
	quit
	rehash
	restart
	rules
	server
	service
	servlist
	squery
	squit
	setname
	silence
	stats
	summon
	time
	topic
	trace
	uhnames
	user
	userhost
	userip
	users
	version
	wallops
	watch
	who
	whois
	whowas
}
