import m242.vitric

// This connection is opened and closed, there is no real point.
fn main() {
	i := vitric.new('irc.freenode.net', 6667, 'vbot', 'vbot', '0.0.0.0') or {
		panic("Couldn't connect")
	}
	i.close()
}
