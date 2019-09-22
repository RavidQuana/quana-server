# == Schema Information
#
# Table name: materials
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Material < ApplicationRecord
    has_many :samples

    def samples_count
        self.samples.count
    end
end
