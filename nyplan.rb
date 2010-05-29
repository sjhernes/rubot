require 'rubygems'; require 'open-uri'; require 'hpricot'; require 'sanitize'
link="http://www.uio.no/studier/emner/alfabetisk/"
sources = ["index.xml","d-f.xml","g-i.xml","j-l.xml","m-o.xml",
           "p-s.xml","t-v.xml","w-z.xml","ae-aa.xml"]
puts "$fagene = {"
sources.length.times do |i|
  (Hpricot(open(link+sources[i]))/"ul.main//a").each do |l|
    begin
      doc = Hpricot(open(l.attributes['href'].slice(0..-10)+"v10/tid-og-sted.xml"))
      first = l.inner_html.strip.lines(" ").first.strip
      Sanitize.clean(first)
      puts "  \""+first+"\" => \""+l.attributes['href'].slice(0..-10)+"\", "
    rescue
    end
  end
end
puts "}"
