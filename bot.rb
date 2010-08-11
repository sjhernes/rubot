#!/usr/local/bin/ruby
["socket","funksjoner.rb",".conf.rb"].each{|w| require w}

class IRC

  def connect()
    @irc = TCPSocket.open($server, $port)
    send "USER rubot Ruby Bot :Ruby Bot" ; send "NICK #{$nick}" ; send "JOIN #{$channel}" ;
  end
  
  def send(s) @irc.send "#{s}\n", 0; end # Sends stuff via TCPSocket connection.
  
  def prarr(a, to) # Must wait between sends to not be kicked for overflow
    a.each { |mes| send "PRIVMSG #{to} :#{mes}" ; Kernel.sleep(1) ; } 
  end
  
  def eval(s, to)
    if(s[0]=="fagtid")
      prarr(finntid(s[1]), to)
    elsif(s[0]=="rss")
      if(s[1]=="add")
        addfeed(s[2], ((s[3]==nil)?2 : s[3])) ; return ;
      end
      prarr(readrss(s[1], s[2].to_i), to)
    elsif(s[0]=="8-ball")
      send "PRIVMSG #{to} :#{$ballsvar[(rand(20)-1)]}"
    elsif(s[0]=="fortune")
      send "PRIVMSG #{to} :#{$fortune[(rand($fortune.length)-1)]}"
    elsif (s[0]=="help")
      prarr($help, to)
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
    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:(.+)$/i
      sa=s.split(" ");             # Prints out the line, and split it.
      3.times { sa.delete_at(0) }  # Will delete unimportant info from s
      sa[0]=sa[0].slice(1..-1)     # Removes the rest of the unimportant stuff
      print $1+": "                # for logging
      sa.each { |st| print st+" "; st=st.downcase } ;puts; # print and downcase
      eval(sa, (($4==$nick)?$1:$4)) # To whom shalt I send stuff, group or person
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
          send "PRIVMSG #{$channel} :"+s
        elsif s == @irc then
          return if @irc.eof
          s = @irc.gets
          handle_server_input(s)
        end
      end
    end
  end
end

irc = IRC.new(); irc.connect()
begin
  irc.main_loop()
rescue Interrupt
rescue Exception => detail
  puts detail.message()
  print detail.backtrace.join("\n")
  retry
end
