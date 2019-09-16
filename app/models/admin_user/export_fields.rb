module AdminUser::ExportFields
	extend ActiveSupport::Concern

	include Exportable

	included do
		exportable [
									 {
											 name: I18n.t('activerecord.models.admin_user.other'),
											 columns: [
													 :id,
													 :first_name,
													 :last_name,
													 :email,
													 { role: ->(user) {user.admin_role ? I18n.t("activerecord.attributes.admin_user.role_#{user.role}") : nil} },
													 :sign_in_count,
													 :last_sign_in_at,
													 :created_at,
													 :updated_at
											 ]
									 }
							 ]
	end
end