require "rubygems"
require "sqlite3"
require "rssparser.rb"

$db = SQLite3::Database.new("bot.db")
# $db.execute( "create table rss (name STRING PRIMARY KEY, link STRING)" )


def readrss(name, t)
  url = $db.execute( "select link from rss where name = ?", name )
  return feed(url.flatten.to_s, t)
end

def addfeed(name, url)
  $db.execute( "insert into rss values ( ?, ? )", name, url )
end
