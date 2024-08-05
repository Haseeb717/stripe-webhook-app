# frozen_string_literal: true

# Interactor to handle a successful payment event from Stripe.
class HandlePaymentSucceeded
  include Interactor

  def call
    invoice = context.event.data.object
    subscription_record = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return context.fail!(error: 'Subscription not found') unless subscription_record

    if subscription_record.may_pay?
      subscription_record.pay!
    else
      context.fail!(error: 'Subscription cannot be marked as paid')
    end
  rescue StandardError => e
    context.fail!(error: e.message)
  end
end
