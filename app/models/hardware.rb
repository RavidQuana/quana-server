# == Schema Information
#
# Table name: hardwares
#
#  id         :bigint           not null, primary key
#  scanner_id :integer          not null
#  version    :string           not null
#

class Hardware < ApplicationRecord
    belongs_to :scanner

    def to_s
        "#{self.scanner.name} #{self.version}"
    end

end
