// internals of the library
module vitric

import net
import net.openssl
import time

[heap]
struct Connection {
	use_ssl bool
mut:
	ssl_conn &openssl.SSLConn = &openssl.SSLConn(0)
	tcp_conn &net.TcpConn     = &net.TcpConn(0)
}

fn (mut c Connection) close() ? {
	if c.use_ssl {
		c.ssl_conn.shutdown()?
	}

	c.tcp_conn.close()?
}

fn (mut c Connection) read(mut buffer []u8) ?int {
	if c.use_ssl {
		return c.ssl_conn.read(mut buffer) or { return err }
	}

	return c.tcp_conn.read(mut buffer) or { return err }
}

fn (mut c Connection) write(buffer []u8) ?int {
	if c.use_ssl {
		return c.ssl_conn.write(buffer)
	}

	return c.tcp_conn.write(buffer)
}

fn (mut c Connection) read_string() ?string {
	unsafe {
		mut buf := &u8(malloc_noscan(4096)) // TODO: data larger than 4K?

		if c.use_ssl {
			len := c.ssl_conn.socket_read_into_ptr(buf, 4096)?

			return tos(buf, len)
		}

		len := c.tcp_conn.read_ptr(buf, 4096)?
		return tos(buf, len)
	}
}

fn (mut c Connection) write_string(s string) ?int {
	if c.use_ssl {
		return c.ssl_conn.write(s.bytes())
	}

	return c.tcp_conn.write_string(s)
}

fn new_connection(host string, port int, use_ssl bool) ?&Connection {
	mut conn := &Connection{
		use_ssl: use_ssl
	}

	conn.tcp_conn = net.dial_tcp('$host:$port')?
	conn.tcp_conn.set_read_timeout(time.infinite)
	conn.tcp_conn.set_write_timeout(30 * time.second)

	if use_ssl {
		conn.ssl_conn = openssl.new_ssl_conn()
		conn.ssl_conn.connect(mut conn.tcp_conn, host)?
	}

	return conn
}
