# == Schema Information
#
# Table name: usages
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint
#  product_id            :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  safe_to_use_status    :integer          default("undetermined"), not null
#  sample                :binary
#  sample_process_status :integer          default("no_process"), not null
#

class Usage < ApplicationRecord  
    belongs_to :user
    belongs_to :product
   
    has_many :usage_symptom_influences
    accepts_nested_attributes_for :usage_symptom_influences, allow_destroy: true, reject_if: :all_blank
  
    has_many :usage_side_effects
    has_many :side_effects, through: :usage_side_effects

    enum safe_to_use_status: {undetermined: 0, safe: 1,  unsafe: 2}
    enum sample_process_status: {no_process: 0, processed: 1,  error_in_process: 2}




end