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
#  material    :string           default("Material"), not null
#  fan_speed   :integer          default(0), not null
#  product_id  :integer          not null
#

require 'test_helper'

class SampleAlphaTest < ActiveSupport::TestCase
	include Rack::Test::Methods

	class SampleAlphaTests < SampleAlphaTest

        setup do
			@brand = Brand.create!(name: "Test")
			@product = Product.create!(name: "Test", brand: @brand)
			@sampler_type = SamplerType.create!(name: "Test")
			@sampler = Sampler.create!(name: "Test", sampler_type: @sampler_type)
			@sample = SampleAlpha.create!(
					product: @product,
					sampler: @sampler,
					material: "Material Test"
			)
		end 

		test "sample without material" do
			assert SampleAlpha.new().invalid?
        end
        
        test "import record data" do
			@sample.insert_csv(File.open("./test/test.csv"))
			assert DataRecord.count == 58
			DataRecord.delete_all
        end
	end

end
