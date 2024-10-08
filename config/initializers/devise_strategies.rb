Warden::Strategies.add(:password_authenticable) do
  def valid?
    params['user'] && params['user']['email'] && params['user']['password']
  end

  def authenticate!
    resource = User.find_by(email: params['user']['email'])
    if resource&.valid_password?(params['user']['password'])
      success!(resource)
    else
      fail!('Invalid Email or Password')
    end
  end
end
