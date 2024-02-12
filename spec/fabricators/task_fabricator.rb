Fabricator(:task) do
  user { Fabricate(:user) }
  description "Check email"
end
