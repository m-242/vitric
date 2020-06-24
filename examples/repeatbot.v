import m242.vitric

fn main() {
	i := vitric.new('irc.freenode.net', 6667, 'vbot-m242-vitric', 'vbot', '0.0.0.0') or {
		panic("Couldn't connect")
	}
	i.logger.log('got a connection', .verbose)
	i.raw('PRIVMSG m242 :bitch please\n')
	i.logger.log('sent startup message', .verbose)
	mut msg := i.read_message()
	for true {
		match msg.command {
			.privmsg {
				s := extract_sender(msg.prefix)
				raw := 'PRIVMSG $s :$msg.content'
				i.raw('$raw\n')
				i.logger.log('SENT: $raw', .info)
			}
			.ping {
				i.raw('PONG $msg.content')
				i.logger.log('got pinged, ponged back', .verbose)
			}
			.quit {
				i.logger.log('Received QUIT message from server', .error)
				i.close()
				exit(1)
			}
			else {}
		}
		msg = i.read_message()
	}
	i.close()
}

fn extract_sender(o string) string {
	mut i := 0
	for char in o {
		if char == 33 { // !
			return o[0..i]
		}
		i++
	}
}
