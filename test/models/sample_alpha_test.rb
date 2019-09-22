require 'test_helper'

class SampleAlphaTest < ActiveSupport::TestCase
	include Rack::Test::Methods

	class SampleAlphaTests < SampleAlphaTest

        setup do
            @material = Material.create!(name: "Test")
			@sample = SampleAlpha.create!(
					material: @material,
					device: 'Test Device'
			)
		end 

		test "sample without material" do
			assert SampleAlpha.new(
                device: 'Test Device'
            ).invalid?
        end
        
        test "import record data" do
			@sample.insert_csv(File.open("./test/test.csv"))
			assert DataRecord.count == 26
			DataRecord.delete_all
        end
	end

end
