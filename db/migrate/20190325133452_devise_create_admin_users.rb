class DeviseCreateAdminUsers < ActiveRecord::Migration[5.2]
	def change
		create_table :admin_users do |t|
			# General
			t.string :first_name, null: false
			t.string :last_name, null: false
			t.string :thumbnail
			t.integer :admin_role_id, index: true

			# Database authenticatable
			t.string :email, null: false, default: ""
			t.string :encrypted_password, null: false, default: ""

			# Recoverable
			t.string :reset_password_token
			t.datetime :reset_password_sent_at

			# Trackable
			t.integer :sign_in_count, default: 0, null: false
			t.datetime :current_sign_in_at
			t.datetime :last_sign_in_at
			t.inet :current_sign_in_ip
			t.inet :last_sign_in_ip

			# Confirmable
			t.string :confirmation_token
			t.datetime :confirmed_at
			t.datetime :confirmation_sent_at
			t.string :unconfirmed_email

			# Lockable
			t.integer :failed_attempts, default: 0, null: false
			t.string :unlock_token
			t.datetime :locked_at

			# Password expirable
			t.datetime :password_changed_at

			# Session limitable
			t.string :unique_session_id, limit: 20

			# Expirable
			t.datetime :last_activity_at
			t.datetime :expired_at

			# 2FA
			t.string :encrypted_otp_secret
			t.string :encrypted_otp_secret_iv
			t.string :encrypted_otp_secret_salt
			t.integer :consumed_timestep
			t.boolean :otp_required_for_login

			t.timestamps null: false
		end

		add_index :admin_users, :email, unique: true
		add_index :admin_users, :reset_password_token, unique: true
		add_index :admin_users, :confirmation_token, unique: true
		add_index :admin_users, :unlock_token, unique: true
		add_index :admin_users, :password_changed_at
		add_index :admin_users, :last_activity_at
		add_index :admin_users, :expired_at
	end
end
