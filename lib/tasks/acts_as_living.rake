namespace :acts_as_living do
  desc 'Install'
  task install_migration: :environment do
    options = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: rake add [options]'
      opts.on('-m', '--model ARG', String) { |model| options[:model] = model }
      opts.on('-s', '--stages ARG', Array) { |stages| options[:stages] = stages }
    end.parse!

    migration_name = "add_life_stages_to_#{options[:model]}"
    timestamps_code = stages.map { |stage| "#{stage}_at:datetime" }.join(' ')
    stages_code = 'stage:integer past_stages:string{array: true, default: []}'

    system "rails g migration #{migration_name} #{stages_code} #{timestamps_code}"
  end
end
 