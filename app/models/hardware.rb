class Hardware < ApplicationRecord
    belongs_to :scanner

    def to_s
        "#{self.scanner.name} #{self.version}"
    end

end