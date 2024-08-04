# frozen_string_literal: true

# Interactor to handle the deletion of a subscription event from Stripe.
class HandleSubscriptionDeleted
  include Interactor

  def call
    subscription = context.event.data.object
    subscription_record = Subscription.find_by(stripe_id: subscription.id)
    return context.fail!(error: 'Subscription not found or not paid') unless subscription_record&.paid?

    subscription_record.update!(status: 'canceled')
    context.subscription_record = subscription_record
  rescue StandardError => e
    context.fail!(error: e.message)
  end
end
