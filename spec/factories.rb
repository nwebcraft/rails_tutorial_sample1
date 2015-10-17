FactoryGirl.define do
  factory :user do
    name                  "Makoto Nishijima"
    email                 "makoto@gmail.com"
    password              "foobar"
    password_confirmation "foobar"
  end
end