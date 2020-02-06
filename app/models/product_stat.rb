class ProductStat  
	include ActiveModel::Model
	attr_accessor :product
	attr_accessor :usage_count
	attr_accessor :symptoms
	attr_accessor :side_effects

end


class ProductStatSymtpomAverage  
	include ActiveModel::Model
	attr_accessor :symptom
	attr_accessor :average
end
