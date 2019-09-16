# encoding: utf-8

namespace :db do
	namespace :seed do
		desc "Seed default settings"
	  	task settings: :environment do
			AppSettings.destroy_all
			ActiveRecord::Base.connection.reset_pk_sequence!(:app_settings)
		end
	end
end 