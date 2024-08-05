# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    stripe_subscription_id { SecureRandom.uuid }
    stripe_customer_id { SecureRandom.uuid }
    status { 'unpaid' }
  end
end
