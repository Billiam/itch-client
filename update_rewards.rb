require 'rubygems'
require 'bundler'
require 'csv'

Bundler.require :default, :development
Dotenv.load

LOGIN_URL = 'https://itch.io/login'
CSV_URL = "https://itch.io/export-purchases/by-date/#{Time.now.year}"
TOTP_URL_FRAGMENT = 'https://itch.io/totp/verify/'
DASHBOARD_URL = 'https://itch.io/dashboard'

COOKIE_PATH = File.join(File.dirname(__FILE__), 'cookies.yml')

agent = Mechanize.new {|a| a.user_agent_alias = 'Mac Safari' }

if File.exist?(COOKIE_PATH)
  agent.cookie_jar.load(COOKIE_PATH)
end

page = agent.get(CSV_URL)

if page.uri.to_s == LOGIN_URL
  form = page.form_with(action: LOGIN_URL)
  form.username = ENV['USERNAME']
  form.password = ENV['PASSWORD']
  page = form.submit
end

if page.uri.to_s.start_with?(TOTP_URL_FRAGMENT)
  form = page.form_with(action: page.uri.to_s)
  puts 'Enter 2FA:'
  code = gets

  form.code = code.chomp
  page = form.submit
end

if page.uri.to_s == DASHBOARD_URL
  agent.cookie_jar.save(COOKIE_PATH)
end

page = agent.get(CSV_URL)
if page.code == '200'
  csv = CSV.new(page.content, headers: true)
  result = {}

  csv.each do |row|
    price = row['product_price'].to_i
    tip = (row['tip'].to_f * 100)

    next if price == 0
    next if tip == 0

    name = row['object_name']
    result[name] ||= 0.0

    result[name] += tip / price
  end
  puts
  tp result.map {|k,v| {game: k, rewards: v.truncate(2)} }
  puts
end
