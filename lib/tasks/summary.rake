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
    Delayed::Job.enqueue GenerateSummary, run_at: 1.day.from_now
  end
end
