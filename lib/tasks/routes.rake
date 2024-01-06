desc "Print out routes"
task :routes => :environment do
  puts "---- Routes for grape API ----"
  Rake::Task["grape:routes"].execute
  puts "\n"
  puts "---- Application Routes ----"
end
