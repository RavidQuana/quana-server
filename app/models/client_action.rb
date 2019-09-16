# == Schema Information
#
# Table name: client_actions
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  required_linkable_type :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ClientAction < ApplicationRecord
	include Autocompletable
	autocompletable query_by: ['lower(name)'], display_as: "%{name}"

	has_many :notification_types, dependent: :nullify

end
