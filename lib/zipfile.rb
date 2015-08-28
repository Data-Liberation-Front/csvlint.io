require 'zip'

class Zipfile

  def self.check!(p)
    if p[:urls].presence && p[:urls].count > 0
      type = :urls
    elsif p[:files].presence
      type = :files
    end

    files = []
    p[type].each do |source|
      if Zipfile.is_zipfile?(source)
        Zipfile.unzip(source, files, type)
      else
        files << source
      end
    end
    p[type] = files
    p
  end

  def self.is_zipfile?(source)
    File.extname(source) == ".zip"
  end

  def self.unzip(source, files, type)
    if type == :urls
      file = Tempfile.new(source.split("/").last)
      file.binmode
      file.write open(source).read
      file.rewind
    else
      file = File.open(source)
    end

    Zip::File.open(file) do |zipfile|
      zipfile.each do |entry|
        next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
        destination = Tempfile.new(entry.name)
        files << destination.path
      end
    end
  end

end
