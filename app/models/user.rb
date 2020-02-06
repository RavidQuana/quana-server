# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  requires_local_auth     :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  token                   :string           not null
#  status                  :integer          default("pending_verification"), not null
#  gender                  :integer          default("male"), not null
#  last_activity_at        :datetime
#  first_name              :string
#  last_name               :string
#  phone_number            :string           not null
#  birth_date              :datetime
#  cannabis_use_years      :integer          default(0), not null
#  cannabis_use_monthes    :integer          default(0), not null
#  cannabis_use_frequency  :string
#  blood_sugar_medications :boolean          default(FALSE), not null
#

class User < ApplicationRecord

    include CodeValidatable

    has_secure_token
    has_many :samples
    has_many :user_symptoms, -> { active } 
    accepts_nested_attributes_for :user_symptoms, allow_destroy: true, reject_if: :all_blank
    has_many :symptoms, through: :user_symptoms
    has_many :user_treatments
    has_many :treatments, through: :user_treatments
    has_many :usages
    has_many :products, through: :usages

    scope :permitted, -> {where(status: [:active, :pending_details]) }


    

    enum status: {pending_verification: 0, pending_details: 1,  active: 2, suspended: 3}
    enum gender: {male: 0, female: 1, other: 2}

    def should_register
        self.first_name.nil?
    end

    def last_usages
        self.usages.safe.order(created_at: :desc).limit(3)
    end

    def used_products
        self.products.distinct
    end

    def next_rank
        Rank.where("minimal_number_of_scans > ?", self.number_of_reviews).order(minimal_number_of_scans: :asc).first   
    end

    def current_rank
        Rank.where("minimal_number_of_scans <= ?", self.number_of_reviews).order(minimal_number_of_scans: :asc).last   
    end

    def number_of_reviews
        self.usages.joins(:usage_symptom_influences).uniq.count
    end


    def stats		
        result = []
        
        self.used_products.each do |product|
            result.push(product.stats_by_user(self.id))
        end
		#if self.transfer_date.present?
		#	t = TransferInfo.new(date: self.transfer_date.to_date, title: "You got 20$", body: "" )
		#	result.push(t)

		#	t = TransferInfo.new(date: self.transfer_date.to_date, 
		#		title: "You need to pay back $#{self.transfer_amount} + $#{fee} fee", 
		#		body: "If you don’t pay us untill #{self.late_payback_date.to_date} will charge you for extra $#{late_fee} fee")
		#	result.push(t)
		#end
		result

	end

end
