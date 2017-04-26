namespace :summary do
  desc "Generate validation summary"
  task :generate => :environment do
    GenerateSummary.perform
  end
end

class GenerateSummary
  def self.perform
    summary = Summary.generate
    summary.save!
  end
end
