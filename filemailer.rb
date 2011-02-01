['rubygems', 'action_mailer'].each { |w| require w }

ActionMailer::Base.delivery_method = :smtp

class MyMailer < ActionMailer::Base

  def initialize(uname, psw)
    ActionMailer::Base.smtp_settings = {
      :tls => true,
      :address => "smtp.uio.no",
      :port => 587,
      :domain => "uio.no",
      :user_name => uname,
      :password => psw,
      :authentication => :login,
    } 
    
  end

  def botmail(to, sender, textfile, atm = false)

    # strip any directory fluff from subject 
    subj = textfile.gsub(/.*\//,'').gsub(/\.\w*/,'')
    
    #standard ActionMailer message setup
    recipients  to
    from        sender
    subject     subj
    t = ""; 
    File.open(textfile, 'r').each_line { |l| t += l }
    body t       
    
    # set up attachment
    #    if atm
    #      aname = atm.gsub(/.*\//,'')
    #      attachments[aname] = File.read(atm)
    #    end
  end
end

# Test    
mailer = Mymailer.new('sjurher', 'P@$$word')
mailer.botmail('sjurher@ulrik.uio.no','Sjur Hernes <sjurher@ulrik.uio.no>','testtekst.txt').deliver
