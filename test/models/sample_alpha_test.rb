# == Schema Information
#
# Table name: samples
#
#  id          :bigint           not null, primary key
#  type        :string           not null
#  user_id     :integer
#  device      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  file_name   :string           default(""), not null
#  protocol_id :integer
#  brand_id    :integer
#  hardware_id :integer
#  card_id     :integer
#  note        :string
#  repetition  :integer          default(0), not null
#  material    :string           default("Material"), not null
#

require 'test_helper'

class SampleAlphaTest < ActiveSupport::TestCase
	include Rack::Test::Methods

	class SampleAlphaTests < SampleAlphaTest

        setup do
            @brand = Brand.create!(name: "Test")
			@sample = SampleAlpha.create!(
					brand: @brand,
					material: "Material Test",
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
