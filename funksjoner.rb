['rubygems','open-uri','hpricot','sanitize','sqlite3','rss/1.0','rss/2.0','hashdump.rb', "filemailer.rb", "MyDocs.rb", "sympa.rb"].each{|w| require w}

$db = SQLite3::Database.new("bot.db")
# $db.execute( "create table rss (name STRING PRIMARY KEY, link STRING)" )

def cybAdduser(array)
  sympa = Sympa.new(@uiomail, @uiopsw, 'cyb-aktiv', 'ifi.uio.no')
end  

def readrss(name, t) # finds url from database, parses it and returns an array
  if (t>5); return ["http://www.justfuckinggoogleit.com"]; end

  s = []
  url = $db.execute( "select link from rss where name = ?", name )
  i = RSS::Parser.parse(open(url.flatten.to_s), false)
  i.items.first(t).each do |it|
    s.push(it.title+" - "+it.link)
  end
  return s
end

def addfeed(name, url)
  $db.execute( "insert into rss values ( ?, ? )", name, url )
end

def finntid(s)
  tel = 0
  fag = $fagene[s.upcase]
  begin
    ret = []
    doc = (Hpricot(open(fag+"h10/tid-og-sted.xml")))
    (doc/"div#right-main").each do |e|
      ((e/"ul").first/"li").each do |i|
        indre = i.inner_html.to_s.gsub('''<br />''', ", - ")
        ret[tel] = Sanitize.clean(indre).gsub("\n", " ").gsub("     ", "")
        tel=tel+1
        if(tel>2)
          return ret
        end
      end
    end
    return ret
  rescue
    feil = ['kurset går ikke dette semesteret']
    return feil
  end
end
