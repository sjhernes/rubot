require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'sanitize'
require 'hashdump.rb'

def finntid(s)
  tel = 0
  bol = false
  fag = $fagene[s.upcase]
  begin
    ret = Array.new
    doc = (Hpricot(open(fag+"h10/tid-og-sted.xml"))).traverse_all_element do |e|
      if(e.name=="h3" or e.name=="h2")
        if (bol)
          return ret
        end
      end
      if(e.name=="li")
        indre = e.inner_html.to_s.gsub('''<br />''', ", - ")
        ret[tel] = Sanitize.clean(indre).gsub("\n", " ").gsub("     ", "")
        tel = tel + 1
        bol=true
      end
    end
    return ret
  rescue
    feil = ['kurset går ikke dette semesteret']
    return feil
  end
end


