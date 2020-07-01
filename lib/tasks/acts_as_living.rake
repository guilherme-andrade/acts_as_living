namespace :acts_as_living do
  desc 'Install'
  task install_migration: :environment do
    options = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: rake add [options]'
      opts.on('-m', '--model ARG', String) { |model| options[:model] = model }
      opts.on('-s', '--stages ARG', Array) { |stages| options[:stages] = stages }
    end.parse!

    timestamps_code = stages.map { |stage| "#{stage}_at:datetime" }.join(' ')

    system "rails g migration add_living_to_#{options[:model]} stage:integer past_stages:string{array: true, default: []} #{timestamps_code}"
  end
end
