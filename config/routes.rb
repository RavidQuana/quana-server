require 'sidekiq/web'

Rails.application.routes.draw do
	# admin dashboard
	devise_for :admin_users, ActiveAdmin::Devise.config
	ActiveAdmin.routes(self)
	root to: redirect('/admin') 

	# REST API
	authenticate :admin_user do
		match '/api/v1/docs' => API, via: :get
	end  
	mount API, at: '/api'

	# admin-related & protected methods
	authenticate :admin_user do
		devise_scope :admin_user do
			get '/otp/setup', to: 'active_admin/devise/otp#index'
			post '/otp/setup', to: 'active_admin/devise/otp#setup'
		end

		mount Sidekiq::Web, at: '/sidekiq'
		get '/swagger', to: 'swagger#index'
		get 'admin/autocomplete/:resource', to: 'admin_utils#autocomplete'
	end

	
	put '/ml/upload_sample', to: 'ml#upload_sample', as: 'upload_sample'
	get '/ml/samples', to: 'ml#samples', as: 'export_samples'
	get '/ml/version', to: 'ml#version'
end