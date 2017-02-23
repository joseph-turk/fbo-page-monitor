require "open-uri"
require "nokogiri"
require "terminal-notifier"

# Set FBO page URL and number of known updates (including Complete View list item)
url = "https://www.fbo.gov/index?s=opportunity&mode=form&id=31a2dbb659e0f3a01b905822c0c0ae66&tab=core&_cview=1"
known_updates = 4 # Set number of updates we already know about

# Initialize connection to site and create empty updates array
page = Nokogiri::HTML(open(url))
updates = []

# Get solicitation name and updates from Nokogiri
solicitation_name = page.css('.agency-header h2').text
update_list = page.css('ul#sb_related_notices li')

# Add all list items in updates ul element to updates array
update_list.each do |update|
  updates.push(update.text)
end

if updates.length > known_updates # If there are more updates than we know about, it was updated
  # Send notification with details of update
  TerminalNotifier.notify(updates.last,
                          :title => "#{solicitation_name} Updated",
                          :sound => "Glass")

  # Log time and details of update
  puts Time.now.strftime("%d/%m/%Y %H:%M")
  puts "The #{solicitation_name} solicitation was updated. Here are the details:"
  puts updates.last
  puts "----------------------------------"
elsif updates.length < known_updates # If there are fewer updates than we know about, something went wrong
  # Send notification that something went wrong
  TerminalNotifier.notify("Something went wrong. Manually check FBO.",
                          :title => "#{solicitation_name} Error",
                          :sound => "Basso")

  # Log that something went wrong
  puts Time.now.strftime("%d/%m/%Y %H:%M")
  puts "Status Check for #{solicitation_name}. Something went wrong. Manually check FBO"
  puts "----------------------------------"
else # If there is the same number of updates that we know about
  # Log time of check and that nothing was changed
  puts Time.now.strftime("%d/%m/%Y %H:%M")
  puts "Status Check for #{solicitation_name}"
  puts "No updates since you last checked."
  puts "----------------------------------"
end
