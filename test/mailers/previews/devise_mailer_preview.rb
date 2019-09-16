class DeviseMailerPreview < ActionMailer::Preview
  # http://localhost:3000/rails/mailers/devise_mailer/

  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(AdminUser.first, 'confirmation_token')
  end

end