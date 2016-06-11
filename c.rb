require 'socket'
SERVER_HOST = "un001.ecc.u-tokyo.ac.jp"
TCP_PORT = 12345

def vote(sel, addr=$addr, name=$name)
  TCPSocket.open(addr, TCP_PORT){|s|
    s.puts "#{name} #{sel}"
    s.gets.chomp
  }
end

def set addr, name
  $addr = addr
  $name = name
end

if $0 == __FILE__
  if ARGV[0]=="--test" 
    ARGV.shift
    $addr =  'localhost'
  else
    $addr = SERVER_HOST
  end
# for test
# $addr = 'localhost'
 $name = ENV['LOGNAME']
 puts vote(ARGV.shift || (print('selection? '); gets.chomp))
end
# v2
