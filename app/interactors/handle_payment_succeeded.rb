# frozen_string_literal: true

# Interactor to handle a successful payment event from Stripe.
class HandlePaymentSucceeded
  include Interactor

  def call
    invoice = context.event.data.object
    subscription_record = Subscription.find_by(stripe_subscription_id: invoice.subscription)

    if subscription_record
      mark_pay(subscription_record)
    else
      context.fail!(error: 'Subscription not found')
    end
  end

  private

  def mark_pay(subscription_record)
    if subscription_record.may_pay?
      subscription_record.pay!
    else
      context.fail!(error: 'Subscription cannot be marked as paid')
    end
  end
end
