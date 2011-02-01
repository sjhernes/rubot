["rubygems", "mechanize"].each {|w| require w }

class Sympa
  def initialize(epost, pass, list, inst)
    # Going into the page
    @maillist = list; @domain = inst;
    @agent = Mechanize.new
    @page = @agent.get('https://sympa.uio.no/'+@domain+'/info/'+@maillist)

    # get the login form, fill and submit
    f = @page.forms.first
    f.email = epost
    f.passwd = pass
    @page = @agent.submit f
  end

  def addUser(subscribers)

    # Navigating to the right place
    @page = @agent.get '/'+@domain+'/admin/'+@maillist
    @page = @agent.get '/'+@domain+'/review/'+@maillist

    # find the form and fill it out for each new subscriber
    subscribers.each do |p|
      f = @page.forms[5]
      f.email = p
      @page = @agent.submit f
    end
  end
end

## Eksempler

# s = Sympa.new('sjurher@ulrik.uio.no', :ditt_passord, 'cyb-aktiv', 'ifi.uio.no')

## Legge til en bruker i liste
## legg merke til at her skal det være et array :)
# s.addUser(['bjørnen@rf.no', 'ugla@hf.no', 'pingvinen@ifi.no']) 
