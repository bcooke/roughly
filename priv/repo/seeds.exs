if Mix.env() == :dev do
  Roughly.Dev.Seeds.run()
else
  raise "Development fixture seeds cannot run outside MIX_ENV=dev"
end
