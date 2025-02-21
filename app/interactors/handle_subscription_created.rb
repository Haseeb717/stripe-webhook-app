# frozen_string_literal: true

# Interactor to handle the creation of a subscription event from Stripe.
class HandleSubscriptionCreated
  include Interactor

  def call
    subscription = context.event['data']['object']
    subscription_record = Subscription.find_or_initialize_by(stripe_subscription_id: subscription['id'])
    unless subscription_record.update(
      stripe_customer_id: subscription['customer'],
      status: 'unpaid'
    )
      context.fail!(error: subscription_record.errors.full_messages.to_sentence)
    end
  end
end
