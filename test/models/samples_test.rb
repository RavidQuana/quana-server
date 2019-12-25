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
			Product.delete_all
			Sampler.delete_all
			SampleAlpha.delete_all
			SampleBeta.delete_all

			@brand = brands(:brand)
			@sampler_type = sampler_types(:sampler_type)
			@protocol = protocols(:protocol)
			@card = cards(:card)

			@product = Product.create!(name: "Test", brand: @brand)
			@sampler = Sampler.create!(name: "Test Device", sampler_type: @sampler_type)
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
		
		test "Gamma Samples Import" do
			file = File.open("./test/test_gamma.bin")
			sample_class = Sample.detect_format(file)
			assert_equal(sample_class, SampleGamma)

			samples = SampleGamma.from_file(file)
			assert_equal(samples, [
				{:sample_code=>1, :time_ms=>100, :sensor_code=>1, :temp=>30, :humidity=>55, :qcm_1=>16325726, :qcm_2=>16325711, :qcm_3=>16325750, :qcm_4=>16325702, :qcm_5=>16325703}, 
				{:sample_code=>2, :time_ms=>200, :sensor_code=>1, :temp=>30, :humidity=>55, :qcm_1=>16325760, :qcm_2=>16325689, :qcm_3=>16325671, :qcm_4=>16325725, :qcm_5=>16325686}, 
				{:sample_code=>3, :time_ms=>300, :sensor_code=>1, :temp=>30, :humidity=>55, :qcm_1=>16325673, :qcm_2=>16325664, :qcm_3=>16325701, :qcm_4=>16325718, :qcm_5=>16325733}
			])
        end
	end
end
