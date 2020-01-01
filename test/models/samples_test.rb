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

			assert_equal(samples[0..10], [
				{:sample_code=>1, :time_ms=>0, :sensor_code=>34, :temp=>39, :humidity=>38, :qcm_1=>0, :qcm_2=>0, :qcm_3=>5987246, :qcm_4=>0, :qcm_5=>0}, 
				{:sample_code=>1, :time_ms=>0, :sensor_code=>35, :temp=>33, :humidity=>38, :qcm_1=>2472457, :qcm_2=>0, :qcm_3=>0, :qcm_4=>5991228, :qcm_5=>5995302}, 
				{:sample_code=>1, :time_ms=>0, :sensor_code=>36, :temp=>31, :humidity=>38, :qcm_1=>0, :qcm_2=>5987147, :qcm_3=>5993648, :qcm_4=>0, :qcm_5=>0}, 
				{:sample_code=>1, :time_ms=>0, :sensor_code=>37, :temp=>31, :humidity=>38, :qcm_1=>5992255, :qcm_2=>5441360, :qcm_3=>0, :qcm_4=>5671606, :qcm_5=>0}, 
				{:sample_code=>1, :time_ms=>0, :sensor_code=>38, :temp=>31, :humidity=>39, :qcm_1=>0, :qcm_2=>5994540, :qcm_3=>0, :qcm_4=>0, :qcm_5=>5920349}, 
				{:sample_code=>1, :time_ms=>0, :sensor_code=>39, :temp=>30, :humidity=>39, :qcm_1=>5993859, :qcm_2=>0, :qcm_3=>5995295, :qcm_4=>0, :qcm_5=>5244155}, 
				{:sample_code=>2, :time_ms=>100, :sensor_code=>34, :temp=>39, :humidity=>38, :qcm_1=>0, :qcm_2=>0, :qcm_3=>8980872, :qcm_4=>0, :qcm_5=>0}, 
				{:sample_code=>2, :time_ms=>100, :sensor_code=>35, :temp=>33, :humidity=>38, :qcm_1=>4948467, :qcm_2=>0, :qcm_3=>0, :qcm_4=>8986846, :qcm_5=>8992962}, 
				{:sample_code=>2, :time_ms=>100, :sensor_code=>36, :temp=>31, :humidity=>38, :qcm_1=>0, :qcm_2=>8980727, :qcm_3=>8990482, :qcm_4=>0, :qcm_5=>0}, 
				{:sample_code=>2, :time_ms=>100, :sensor_code=>37, :temp=>31, :humidity=>39, :qcm_1=>8988387, :qcm_2=>8353823, :qcm_3=>0, :qcm_4=>8668419, :qcm_5=>0}, 
				{:sample_code=>2, :time_ms=>100, :sensor_code=>38, :temp=>31, :humidity=>39, :qcm_1=>0, :qcm_2=>8991818, :qcm_3=>0, :qcm_4=>0, :qcm_5=>8917264}
			])
        end
	end
end
