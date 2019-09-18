namespace :db do
	namespace :seed do
		desc "Seed root admin user"
	  	task root_admin: :environment do
			# clear all accounts
			AdminUser.destroy_all

			# reset auto increment key
			ActiveRecord::Base.connection.reset_pk_sequence!(:admin_users)

	  		AdminUser.create(
	  			email: 'admin@monkeytech.co.il', 
	  			password: 'Monkey12', 
	  			first_name: 'Awesome', 
	  			last_name: 'Monkey',
	  			admin_role: AdminRole.find_by(name: 'administrator')
			)

			AdminUser.create(
				email: 'vova@monkeytech.co.il', 
				password: 'Kofkof12', 
				first_name: 'Awesome', 
				last_name: 'Monkey',
				admin_role: AdminRole.find_by(name: 'administrator')
		  )
	  	end	  	
	end
end