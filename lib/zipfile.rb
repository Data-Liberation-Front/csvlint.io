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
      # Create a uniquely named folder to drop the downloaded file into
      folder = FileUtils.mkdir_p(File.join('/', 'tmp', 'csvs', source.split("/").last + Time.now.to_i.to_s))
      # Create the file in the new folder and write the contents of the URL into it
      file = File.new(File.join(folder, source.split("/").last), "w+")
      file.binmode
      file.write open(source).read
      file.rewind
    else
      file = File.join('/', 'tmp', source)
    end

    Zip::File.open(file) do |zipfile|
      # Create a uniquely named folder to unzip into (avoids name collisions)
      folder_name = (File.basename(file) + Time.now.to_i.to_s).parameterize
      folder = File.join(File.expand_path("..", file), folder_name)
      FileUtils.mkdir_p(folder)
      zipfile.each do |entry|
        next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
        # Unzip into the created folder
        destination = File.join(folder, entry.name)
        entry.extract(destination)
        # Add the file location to the files array - We drop the /tmp part of the folder name, as the controller assumes this already
        files << destination.split("/").drop(2).join("/")
      end
    end
  end

end
