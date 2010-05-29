require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'hashdump.rb'

def feed(url, t)
  if (t>5); return ["http://www.justfuckinggoogleit.com"]; end
  i = RSS::Parser.parse(open(url), false)
  s = Array.new
  i.items.first(t).each do |it|
    s.push(it.date.to_s+": "+it.title+" - "+it.link)
  end
  return s
end

