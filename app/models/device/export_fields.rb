module Device::ExportFields
	extend ActiveSupport::Concern

	include Exportable

	included do
		exportable [
									 {
											 name: I18n.t('activerecord.models.device.other'),
											 columns: [
													 :id,
													 { owner: ->(device) { device.owner.try(:name) } },
													 :device_token,
													 { os_type: ->(device) { device.os_type ? I18n.t("activerecord.attributes.device.type_#{device.os_type}") : nil } },
													 :device_type,
													 :os_version,
													 :app_version,
													 :failed_attempts,
													 :is_sandbox,
													 :created_at,
													 :updated_at
											 ]
									 }
							 ]
	end
end