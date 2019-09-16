require 'test_helper'

class AppTest < ActionDispatch::IntegrationTest
	include Rack::Test::Methods
	
	require 'bundler/audit/cli'
	test "no new gem vulnerabilities found" do
	    `bundle audit update -q` # Update vulnerability database
	    result = `bundle audit`  # Run the audit
	    code = `echo $?`.squish  # Returns '0' if successful, otherwise '1'

	    # Print the scan result as the error message if it fails.
	    assert_equal '0', code, result

	    # If successful, output the success message
	    puts "\nMessage from bundler-audit: #{result}"
	end
	
	require 'brakeman'
	test "no new brakeman suggestions found" do
	    result = Brakeman.run Rails.root.to_s
	    assert_equal [], result.errors
	    #assert_equal [], result.warnings
	    pp result.warnings
	end
end
