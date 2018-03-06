require 'rubygems'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome
driver.get "http://hr025-win-0.aws.psadmin.cloud:8000/"

element = driver.find_element (:css, "body > center > a")
element.click

puts "Page title is #{driver.title}"
driver.quit