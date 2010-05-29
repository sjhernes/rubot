require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'hashdump.rb'

def feedMe(t)
  if (t>3)
    return ["http://www.justfuckinggoogleit.com"]
  end 
  i = RSS::Parser.parse(open("http://www.dagbladet.no/rss/magasinet/oppskrift/"), false)
  s = Array.new
  i.items.first(t).each do |it|
    s.push(it.date.to_s+": "+it.title+" - "+it.link)
  end
  return s
end

def nytt(t)
  if (t>5)
    return ["http://www.justfuckinggoogleit.com"]
  end
  i = RSS::Parser.parse(open("http://www.aftenposten.no/eksport/rss-1_0/?utvalg=siste100"), false)
  s = Array.new
  i.items.first(t).each do |it|
    s.push(it.title+" - "+it.link)
  end
  return s
end

def hnytt(t)
  if (t>5)
    return ["http://news.ycombinator.com"]
  end
  i = RSS::Parser.parse(open("http://news.ycombinator.com/rss"), false)
  s = Array.new
  i.items.first(t).each do |it|
    s.push(it.title+" - "+it.link)
  end
  return s
end
