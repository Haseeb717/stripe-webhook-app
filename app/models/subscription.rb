# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                     :bigint           not null, primary key
#  status                 :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_customer_id     :string
#  stripe_subscription_id :string           not null, unique
#

# Model representing a subscription.
class Subscription < ApplicationRecord
  validates :stripe_subscription_id, presence: true, uniqueness: true
  validates :status, presence: true
end
