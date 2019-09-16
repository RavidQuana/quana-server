class Numeric
  	def percent_of(n)
    	n > 0 ? self.to_f / n.to_f * 100.0 : 0
  	end

  	def percent_of_max(n, max=100.0)
    	[n > 0 ? self.to_f / n.to_f * 100.0 : 0, max].min
  	end
end