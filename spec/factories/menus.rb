# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :menu do
    type 1
    key "MyString"
    order 1
    link_id 1
  end
end
