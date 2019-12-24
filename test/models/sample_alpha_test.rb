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
	

	class SampleAlphaTests < SampleAlphaTest

        setup do
			Brand.delete_all
			Product.delete_all
			SamplerType.delete_all
			Sampler.delete_all
			Protocol.delete_all
			SampleAlpha.delete_all
			SampleBeta.delete_all
			Card.delete_all

			@brand = Brand.create!(name: "Test")
			@product = Product.create!(name: "Test", brand: @brand)
			@sampler_type = SamplerType.create!(name: "Test Device")
			@sampler = Sampler.create!(name: "Test Device", sampler_type: @sampler_type)
			@protocol = Protocol.create!(name: "Test", description: "Test")
			@card = Card.create!(name: "Test")
		end 

		test "Alpha Sample Import" do
			file = File.open("./test/test_alpha.csv")
			sample_class = Sample.detect_format(file)
			assert_equal(sample_class, SampleAlpha)

			sample = sample_class.create!(
				protocol: @protocol,
				product: @product,
				sampler: @sampler,
				card: @card)

			file.rewind
			sample.insert_sample(file)
			assert_equal(sample.data.count, 57)
			sample.data.delete_all
		end
		
		test "Beta Sample Import" do
			file = File.open("./test/test_beta.csv")
			sample_class = Sample.detect_format(file)
			assert_equal(sample_class, SampleBeta)

			sample = sample_class.create!(
				protocol: @protocol,
				product: @product,
				sampler: @sampler,
				card: @card)

			file.rewind
			sample.insert_sample(file)
			assert_equal(sample.data.count, 503)
			sample.data.delete_all
		end
		
		test "Gamma Sample Import" do
			file = File.open("./test/test_gamma.bin")
			sample_class = Sample.detect_format(file)
			assert_equal(sample_class, SampleGamma)

			samples = SampleGamma.from_file(file)
			assert_equal(samples, [
				{:time=>80, :sensor_id=>3, :temp=>5, :humidity=>6, :qcm_1=>16, :qcm_2=>17, :qcm_3=>18, :qcm_4=>19, :qcm_5=>20}, 
				{:time=>80, :sensor_id=>3, :temp=>5, :humidity=>6, :qcm_1=>16, :qcm_2=>17, :qcm_3=>18, :qcm_4=>19, :qcm_5=>20}
			])
        end
	end

end
