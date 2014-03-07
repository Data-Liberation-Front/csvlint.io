require 'zip'

class Zipfile
  
  def self.check!(p)
    if p[:urls].presence && p[:urls].count > 0
      type = :urls
    else
      type = :files
    end
    files = []
    p[type].each do |source|
      if Zipfile.is_zipfile?(source) 
        Zipfile.unzip(source, p[type], type)
      else
        files << source 
      end
    end
    p[type] = files
    p
  end

  def self.is_zipfile?(source)
    if source.respond_to?(:tempfile)
      return source.content_type == "application/zip"
    else
      return File.extname(source) == ".zip"
    end
  end

  def self.unzip(source, files, type)
    if type == :urls
      file = Tempfile.new(source.split("/").last)
      file.binmode
      file.write open(source).read
      file.rewind
    else
      file = source.path
    end
    Zip::File.open(file) do |zipfile|
      zipfile.each do |entry|
        next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
        files << Zipfile.read(entry)
      end
    end
  end

  def self.read(entry)
    filename = entry.name
    basename = File.basename(filename)
    tempfile = Tempfile.new(basename)
    tempfile.write(entry.get_input_stream.read)
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(:filename => filename, :tempfile => tempfile)
  end
  
end