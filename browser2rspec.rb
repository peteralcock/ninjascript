require 'selenium-webdriver'
require 'rspec/core'

# create new instance of selenium webdriver with chrome browser
browser = Selenium::WebDriver.for :chrome

# set window size
browser.manage.window.resize_to(1440, 900)

# record actions for 120 seconds
@start_time = Time.now
@end_time = Time.now + 120

# create array to store recorded actions
recorded_actions = []

while Time.now < @end_time
  # record each action taken 
  action = browser.action 
  recorded_actions << action
end

# add recorded actions to rspec capybara feature spec
recorded_actions.each do |action|
  RSpec.feature do
    scenario action do 
      execute action 
    end
  end
end

# export feature spec file
file_name = 'integration_test_generated.rb'
File.open(file_name, 'w') do |file| 
  file.write(RSpec.feature)
end

# close selenium webdriver
browser.quit
