Fabricator(:user) do
  email { "#{Faker::Name.name.parameterize}@example.com" }
  password { "Password1" }
  password_confirmation { |attrs| attrs[:password] }
end
