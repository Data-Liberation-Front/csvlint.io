task :cleanup_dupes => :environment do
  vals = []

  validations = Validation.where(:url.ne => nil).order_by(:created_at.desc)

  validations.each do |v|
    if vals.include?(v.url)
      v.delete
    else
      vals << v.url
    end
  end

end
