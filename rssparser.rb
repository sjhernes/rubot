require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'hashdump.rb'

def feed(url, t)
  i = RSS::Parser.parse(open(url), false)
  s = Array.new
  i.items.first(t).each do |it|
    s.push(it.date.to_s+": "+it.title+" - "+it.link)
  end
  return s
end

def feedMe(t)
  if (t>3); return ["http://www.justfuckinggoogleit.com"]; end
  return feed("http://www.dagbladet.no/rss/magasinet/oppskrift/", t)
end

def nytt(t)
  if (t>5); return ["http://www.justfuckinggoogleit.com"]; end
  return feed("http://www.aftenposten.no/eksport/rss-1_0/?utvalg=siste100"), t)
end

def hnytt(t)
  if (t>5); return ["http://news.ycombinator.com"]; end 
  feed("http://news.ycombinator.com/rss"), t)
end
