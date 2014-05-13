namespace :summary do
  desc "Generate validation summary"
  task :generate => :environment do
    summary = Summary.generate
    summary.save!
  end  
end