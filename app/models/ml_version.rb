# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  brand_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MLVersion < ApplicationRecord
    include Autocompletable
    autocompletable query_by: ['name'], display_as: "%{to_s}"

    enum status: { ready: 0, ready2: 1, active: 2 }
end
