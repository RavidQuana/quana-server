# == Schema Information
#
# Table name: app_settings
#
#  id                   :bigint           not null, primary key
#  key                  :string           not null
#  value                :string
#  data_type            :integer          default("string")
#  description          :string(4096)
#  is_client_accessible :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class AppSettings < ApplicationRecord
	CSV_ARRAY_PARSER = /,?(?:(?:"((?:[^"]|"")*)")|([^,]*))/

	validates :data_type, presence: true
	validates :key, uniqueness: true, presence: true
	validates :is_client_accessible, inclusion: { in: [true, false] }

	scope :client_accessible, -> { where(is_client_accessible: true) }

	enum data_type: { string: 0, integer: 1, decimal: 2, boolean: 3, price: 4, csv_array: 5 }

	around_destroy :remove_from_cache

	def self.get(key)
		Rails.cache.fetch("settings/#{key}") do
			setting = find_by(key: key)
			setting.present? ? setting.value : nil
		end
	end

	def value
		cast_to_type(read_attribute(:value))
	end

	def value=(v)
		write_attribute(:value, v)
		Rails.cache.write("settings/#{key}", cast_to_type(v))
	end

	private
		def remove_from_cache
			Rails.cache.delete("settings/#{key}")
			yield
		end

		def cast_to_type(v)
			return v if string?
			return (begin Kernel.Integer(v) rescue 0 end) if integer?
			return (begin Kernel.Float(v) rescue 0.0 end) if decimal?
			return (v == true || v =~ (/^(true|t|yes|y|1)$/i) ? true : false) if boolean?
			return (begin Money.from_amount(v.to_f) rescue Money.from_amount(0) end) if price?
			return (v.split(CSV_ARRAY_PARSER).reject(&:blank?)) if csv_array?

			return v
		end
end
