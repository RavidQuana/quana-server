MoneyRails.configure do |config|
  	# set the default currency
  	config.default_currency = :ils

  	# set the default format
	config.default_format = {
    	no_cents_if_whole: true
  	}
end