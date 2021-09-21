namespace :summary do
  desc "Generate validation summary"
  task :generate => :environment do
    SummaryGenerator.new.call
  end
end
