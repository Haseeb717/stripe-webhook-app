# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_subscription_id, null: false, unique: true
      t.string :stripe_customer_id
      t.string :status, null: false

      t.timestamps
    end

    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end
