# frozen_string_literal: true

# Interactor to handle a successful payment event from Stripe.
class HandlePaymentSucceeded
  include Interactor

  def call
    invoice = context.event.data.object
    subscription_record = Subscription.find_by(stripe_id: invoice.subscription)
    return context.fail!(error: 'Subscription not found') unless subscription_record

    subscription_record.update!(status: 'paid')
    context.subscription_record = subscription_record
  rescue StandardError => e
    context.fail!(error: e.message)
  end
end
