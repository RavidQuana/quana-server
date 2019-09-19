class DataExporter
	include Sidekiq::Worker
    sidekiq_options queue: 'data', retry: false
      
    

	def perform(email, resource, ids, includes, filters)
		begin
	  		records = resource.titleize.gsub(/\s+/, "").constantize.where(id: ids)
	  		filename = "#{resource}-export-#{Time.zone.now.to_i}"
	  
	  		records.includes(*includes) if includes.present?
	  
	  		x_filename = "#{Rails.root}/tmp/#{filename}.xlsx"
	  		s = records.to_xlsx(filters)
	  		File.open(x_filename, 'w') { |f| f.write(s.read) }

	  		ApplicationMailer.data_export(email, x_filename, resource).deliver_now
	  		File.delete(x_filename) if File.exist?(x_filename)
		rescue => e
	  		Bugsnag.notify(e)
		end
  	end
end