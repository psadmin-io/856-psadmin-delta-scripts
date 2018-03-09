require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

describe "LoginAndPUMDashboard" do

  before(:each) do
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "https://www.katalon.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end
  
  if "test_login_and_p_u_m_dashboard" do
    @driver.get "http://hr025-win-0.aws.psadmin.cloud:8000/"
    @driver.find_element(:xpath, "//h4").click
    @driver.find_element(:id, "userid").clear
    @driver.find_element(:id, "userid").send_keys "PS"
    @driver.find_element(:id, "pwd").clear
    @driver.find_element(:id, "pwd").send_keys "PS"
    @driver.find_element(:xpath, "//form[@id='login']/div/div").click
    @driver.find_element(:name, "Submit").click
    @driver.find_element(:name, "PT_NAVBAR$IMG").click
    # ERROR: Caught exception [ERROR: Unsupported command [selectFrame | index=0 | ]]
    @driver.find_element(:id, "PTNUI_MENU_ICN$2").click
    @driver.find_element(:id, "PTNUI_NB_CNTREC_PTNUI_LINK$23").click
    @driver.find_element(:id, "PTNUI_NB_CNTREC_PTNUI_LINK$1").click
    @driver.find_element(:id, "PTNUI_NB_CNTREC_PTNUI_LINK$2").click
    @driver.find_element(:id, "PTNUI_NB_CNTREC_PTNUI_LINK$0").click
  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
