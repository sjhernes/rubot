#!/usr/local/bin/ruby

require "socket"
require "fagtid.rb"
require "rssparser.rb"
require "fortune.rb"
require "datbas.rb"

class IRC

  def initialize(server, port, nick, channel)
    @server = server; @port = port; @nick = nick; @channel = channel;
  end

  def send(s)
    @irc.send "#{s}\n", 0 
  end

  def connect()
    @irc = TCPSocket.open(@server, @port)
    send "USER rubot Ruby Bot :Ruby Bot"
    send "NICK #{@nick}"
    send "JOIN #{@channel}"
  end

  def eval(s, to)
    if(s[0]=="fagtid")
      prarr(finntid(s[1]), to)
    elsif(s[0]=="rss")
      if(s[1]=="add")
        addfeed(s[2], s[3])
        return
      end
      prarr(readrss(s[1], s[2].to_i), to)
    elsif(s[0]=="8-ball")
      send "PRIVMSG #{to} :#{$ballsvar[(rand(20)-1)]}"
    elsif(s[0]=="fortune")
      send "PRIVMSG #{to} :#{$fortune[(rand($fortune.length)-1)]}"
    elsif (s[0]=="help")
      prarr($help, to)
    else
      response = ["vat u try to do?", "I'll go down fighting, don't even try", 
                  "go hide, or I'll unleash awesomeness", 
                  "I'll call your mom for another date if you don't stop messing"]
      send "PRIVMSG #{to} :"+response[rand(4)-1]
    end
  end
  
  def prarr(a, to)
    a.each do |mes|
      send "PRIVMSG #{to} :#{mes}"
      Kernel.sleep(0.1)
    end
  end

  def handle_server_input(s)
    case s.strip
    when /^PING :(.+)$/i
      send "PONG :#{$1}"
    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]PING (.+)[\001]$/i
      puts "[ CTCP PING from #{$1}!#{$2}@#{$3} ]"
      send "NOTICE #{$1} :\001PING #{$4}\001"
    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]VERSION[\001]$/i
      puts "[ CTCP VERSION from #{$1}!#{$2}@#{$3} ]"
      send "NOTICE #{$1} :\001VERSION Ruby-irc v0.042\001"
#    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:@(.+)\s(.+)$/i
#      puts "[ EVAL #{$5} from #{$1}!#{$2}@#{$3} ]"
#      eval([$5.downcase, $6], (($4==@nick)?$1:$4))
    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:@(.+)$/i
      s=s.split(" ")
      3.times { s.delete_at(0) }
      s[0]=s[0].slice(2..-1)
      s.each { |st| st=st.downcase }
      eval(s, (($4==@nick)?$1:$4))
    else
      puts s
    end
  end

  def main_loop()
    while true
      ready = select([@irc, $stdin], nil, nil, nil)
      next if !ready
      for s in ready[0]
        if s == $stdin then
          return if $stdin.eof
          s = $stdin.gets
          send "PRIVMSG #{@channel} :"+s
        elsif s == @irc then
          return if @irc.eof
          s = @irc.gets
          handle_server_input(s)
        end
      end
    end
  end
end

irc = IRC.new('irc.ifi.uio.no', 6667, 'Rubot', '#cyb')
irc.connect()

begin
  irc.main_loop()
rescue Interrupt
rescue Exception => detail
  puts detail.message()
  print detail.backtrace.join("\n")
  retry
end
