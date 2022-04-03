# Itch Client

An itch.io screenscraping and automation utility.

Originally written to help automate community copy rewards based on purchases and tips.

## Features

* Log in and save cookies
* Fetch and parse purchase CSV data, optionally by date
* Fetch and parse reward redemption CSV data
* Fetch reward data
* Add/update/delete rewards
* Fetch and update game theme and custom CSS data

## How fragile is it?

Very fragile. Enjoy it while it lasts!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'itch_client'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install itch_client

## Usage

### Authentication

The itch client requires a username and password. It doesn't handle captchas, so ironically, 2fa must be enabled.

```ruby
client = Itch.new(username: ENV['itch_username'], password: ENV['itch_password'], cookie_path: "./cookies.yml")
client.totp = -> { puts "Enter your 2fa code: \n"; gets.chomp }
client.logged_in?
#=> false
client.login
client.logged_in?
#=> true
```

After logging in, a cookie file will be saved at the `cookie_path` location if provided, and it won't be necessary to log in again until the cookie expires.

## Purchases

Fetch purchases csv data

```ruby
data = client.purchases.history
#=> #<CSV io_type:Hash encoding:ASCII-8BIT lineno:0 col_sep:"," row_sep:"\n" quote_char:"\"" headers:true>
data.each do |row|
  row.to_h
#=> {
#  "id"=>"123456",
#  "object_name"=>"MyGame",
#  "amount"=>"3.00",
#  "source"=>"paypal",
#  "created_at"=>"2016-01-07 23:41:31 UTC",
#  "email"=>"email@example.com",
#  "full_name"=>nil,
#  "donation"=>"false",
#  "on_sale"=>"false",
#  "country_code"=>"CA",
#  "ip"=>"0.0.0.0",
#  "product_price"=>"0",
#  "tax_added"=>"0.00",
#  "tip"=>"3.00",
#  "marketplace_fee"=>"0.30",
#  "source_fee"=>"0.40",
#  "payout"=>"payout_paid",
#  "amount_delivered"=>"2.00",
#  "currency"=>"USD",
#  "source_id"=>"PAYID-ABCDEFGHIJKLMNOP",
#  "billing_name"=>nil,
#  "billing_street_1"=>nil,
#  "billing_street_2"=>nil,
#  "billing_city"=>nil,
#  "billing_state"=>nil,
#  "billing_zip"=>nil,
#  "billing_country"=>nil
# }
end
```

Fetch one year of purchases

```ruby
client.purchases.history_by_year(2021)
```

Fetch one month of purchases

```ruby
client.purchases.history_by_month(5, 2019)
```

## Games

Find game by ID

```ruby
client.game(12345)
```

Find game by name

```ruby
client.game(name: 'MyItchGame')
client.id
# => 12345
```

### Game theme

Fetch game theme information

```ruby
client.game(12345).theme
#=> {
#  "link_color"=>"#00ff00",
#  "screenshots_loc"=>"hidden",
#  "button_color"=>"#00ff00",
#  "banner_position"=>"align_center",
#  "background_repeat"=>"repeat-x",
#  "default_screenshots_loc"=>"sidebar",
#  "background_position"=>"align_right",
#  "header_font_family"=>"serif",
#  "background_image"=>
#   {"url"=>"https://itch.io/dashboard/upload-image?upload_id=54321",
#    "thumb_url"=>"https://img.itch.zone/aBcDeFgHiJkLmNoPqRsTuVwXyZ/original/aBcDe.png",
#    "id"=>6027863},
#  "font_size"=>"large",
#  "bg_color"=>"#00ff00",
#  "header_text_color"=>"#00ff00",
#  "css"=>"body { color: blue; }",
#  "bg2_color"=>"#00ff00",
#  "banner_image"=>
#   {"url"=>"https://itch.io/dashboard/upload-image?upload_id=12345",
#    "thumb_url"=>"https://img.itch.zone/aBcDeFgHiJkLmNoPqRsTuVwXyZ/original/aBcDe.png",
#    "id"=>12345678},
#  "text_color"=>"#00ff00",
#  "font_family"=>"pixel"
# }
```

Update game theme information

```ruby
game = client.game(12345)
new_theme = game.theme
new_theme['button_color'] = "#cccccc"
new_theme['css'] = "body { background-color: orange; }"
game.theme = new_theme
```

CSS Shortcuts

```ruby
client.game(12345).css
#=> body { background-color: orange; }
client.game(12345).css = "body { background-color: green; }"
```

### Reviews

Fetch current reviews

```ruby
reviews = client.game(12345).reviews.list
#=>
[
  #<Itch::Review:0x0000557aa98c7930
  @id="123456789",
  @user_name="Billiam",
  @user_id="billiam",
  @date=<DateTime: 2022-04-03T10:02:00+00:00>,
  @stars=4,
  @review=[
    "I really like this game",
    "So much that I've added a second paragraph"
  ],
]
```

### Rewards

Fetch reward CSV data

```ruby
client.game(12345).rewards.history
#=> #<CSV io_type:Hash encoding:ASCII-8BIT lineno:0 col_sep:"," row_sep:"\n" quote_char:"\"" headers:true>
data.each do |row|
  row.to_h
#=> 
# {
#   "reward"=>"Free Community Copy",
#   "date"=>"2021-05-21 06:56:34 UTC",
#   "contact"=>nil,
#   "fulfilled"=>"false",
#   "shortcode"=>"VKDC-W4DD"
# }
end
```

#### Fetch current rewards

```ruby
client.game(12345).rewards.list
#=>
[
  #<Itch::Reward:0x0000557aa98c7930
  @amount=1,
  @archived=false,
  @claimed=0,
  @description="<p>Hello. This is a reward description</p>",
  @id=123456789,
  @price="$5.00",
  @title="My Reward">,
]
```

#### Modify a reward

Note: All rewards must be saved at once as follows, even if only one is being modified

```ruby
rewards = client.game(12345).rewards.list
rewards.first.amount
#=> 10
rewards.first.amount = 15
#=> 15
client.game(12345).rewards.save(rewards)
```

#### Add a reward

```ruby
rewards = client.game(12345).rewards.list
new_reward = Itch::Reward.new(
  title: "My New Reward",
  description: "<p>Full content of reward description</p>",
  amount: 10,
  price: "$10.00"
)
rewards << new_reward
client.game(12345).rewards.save(rewards)
```

#### Archive a reward

```ruby
rewards = client.game(12345).rewards.list
rewards.first.archived = true
client.game(12345).rewards.save(rewards)
```

#### Remove rewards

```ruby
rewards = client.game(12345).rewards.list
filtered_rewards = rewards.select do |reward|
  reward.amount > 5
end
client.game(12345).rewards.save(filtered_rewards)
```

## Bundles

Fetch current bundles

```ruby
client.bundles.list

#=>
[
  #<Itch::Bundle:0x0000557aa98c7930
  @id="123",
  @earnings=BigDecimal(123.00),
  @price=BigDecimal(10.00),
  @purchases=10,
  @title="My Bundle!"
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Billiam/itch-client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
