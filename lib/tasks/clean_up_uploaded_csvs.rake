namespace :clean_up do
  task :csvs => :environment do
    Validation.clean_up(24)
  end
end
