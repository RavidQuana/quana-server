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


    def query_humanize
        if !self.query.present?
            return ""
        end
        
        resource = ActiveAdmin.application.namespaces[:admin].resources['Sample']
        filters = Sample.ransack(self.query).conditions.map{ |p| ActiveAdmin::Filters::ActiveFilter.new(resource, p.dup) }

        filters.map{|f| f.label}.join(", ")
    end
end
