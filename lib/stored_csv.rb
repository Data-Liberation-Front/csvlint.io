require 'mongoid/grid_fs'

class StoredCSV

  def self.save(file, filename = nil)
    stored_csv = Mongoid::GridFs.put(file)
    stored_csv.metadata = { filename: filename } if filename
    stored_csv.save

    file.close
    file.unlink
    stored_csv
  end

end
