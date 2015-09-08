require 'mongoid/grid_fs'

class StoredCSV

  def self.save(file, filename)
    stored_csv = Mongoid::GridFs.put(file)
    stored_csv.metadata = { filename: filename }
    stored_csv.save

    file.close
    file.unlink rescue nil
    stored_csv
  end

end
