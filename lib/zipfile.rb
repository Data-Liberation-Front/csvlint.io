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
      FileUtils.mkdir_p(File.join('/', 'tmp', 'csvs', DateTime.now.to_s))
      file = File.new(File.join('/', 'tmp', 'csvs', DateTime.now.to_s, source.split("/").last), "w+")
      file.binmode
      file.write open(source).read
      file.rewind
    else
      file = File.join('/', 'tmp', source)
    end

    Zip::File.open(file) do |zipfile|
      zipfile.each do |entry|
        next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
        destination = File.join(File.expand_path("..", file), entry.name)
        entry.extract(destination)
        files << destination.split("/").drop(2).join("/")
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
