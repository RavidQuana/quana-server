# == Schema Information
#
# Table name: ranks
#
#  id                      :bigint           not null, primary key
#  name                    :string           not null
#  minimal_number_of_scans :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  image                   :string
#

class Rank < ApplicationRecord
    include Uploadable
	mount_field :image
end
