// internals of the library
module vitric

import net

// SSL or not logic should be added here
fn dial(host string, port int) ?net.Socket {
	return net.dial(host, port)
}
