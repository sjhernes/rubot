['rubygems', 'gdocs4ruby'].each {|w| require w }

class MyDocs
  def initialize(uname, psw)
    @service = GDocs4Ruby::Service.new    
    @service.authenticate(uname, psw)
    @documents = @service.files
  end

  def listIds(name)
    rtrn = []
    @documents.each { |d| rtrn << d.id.gsub(/spreadsheet:/,'') if d.title == name }
    return rtrn
  end

  def getDoc(idn)
    return GDocs4Ruby::Spreadsheet.find(@service, {:id => idn})
  end

  def downloadDocAs(name, type)
    listIds(name).each do |l|
      d = getDoc(l)
      d.download_to_file(type, Dir.pwd+'/'+name+'.'+type)
    end
  end
end

# examples

# test = MyDocs.new('sjhernes@gmail.com', 'Pa$$word')
# puts test.listIds('Cyb aktiv')
# test.downloadDocAs('Cyb aktiv', 'csv')
