#!/usr/bin/ruby

require 'socket'

PORT_RANGE = 1..128
HOST = 'google.com'
TIME_TO_WAIT = 5 # seconds

sockets = PORT_RANGE.map do |port|
  socket = Socket.new(:INET, :STREAM)
  remote_addr = Socket.sockaddr_in(port, HOST)

  begin
    socket.connect_nonblock remote_addr
  rescue Errno::EINPROGRESS
  end

  socket
end

loop do
  _, writable, _ = IO.select(nil, sockets, nil, TIME_TO_WAIT)
  break unless writable

  writable.each do |socket|
    begin
      socket.connect_nonblock(socket.remote_address)
    rescue Errno::EISCONN
      puts "#{HOST}:#{socket.remote_address.ip_port} accepts connection..."
      sockets.delete socket
    rescue Errno::EINVAL
      sockets.delete socket
    end
  end

end
