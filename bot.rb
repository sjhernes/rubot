#!/usr/local/bin/ruby

require "socket"
require "fagtid.rb"
require "rssparser.rb"

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
    end
    if(s[0]=="mat")
      prarr(feedMe("http://www.dagbladet.no/rss/magasinet/oppskrift/", s[1].to_i), to) 
    end
    if(s[0]=="skjera?")
      prarr(nytt("http://www.aftenposten.no/eksport/rss-1_0/?utvalg=siste100", s[1].to_i), to)
    end
    if(s[0]=="hn")
      prarr(feed("http://news.ycombinator.com/rss", s[1].to_i), to)
    end
  end
  
  def evalen(s, to)
    if (s=="help")
      prarr(["Dette er Rubot - en ruby bot", 
             "Jeg har følgende funksjonalitet foreløpig:",
             "@fagtid emnekode - gir forelesningstider i faget",
             "@skjera? tall - Siste nytt, antall rss fra aftenposten",
             "@mat tall - oppskrifter fra dagbladets rss-feed"], to)
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
    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:@(.+)\s(.+)$/i
      puts "[ EVAL #{$5} from #{$1}!#{$2}@#{$3} ]"
      eval([$5.downcase, $6], (($4==@nick)?$1:$4))
    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:@(.+)$/i
      evalen($5.downcase, (($4==@nick)?$1:$4))
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
