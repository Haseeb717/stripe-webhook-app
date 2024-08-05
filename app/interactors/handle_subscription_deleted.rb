# frozen_string_literal: true

# Interactor to handle the deletion of a subscription event from Stripe.
class HandleSubscriptionDeleted
  include Interactor

  def call
    subscription = context.event.data.object
    subscription_record = find_subscription(subscription.id)
    return unless subscription_record

    cancel_subscription(subscription_record)
  rescue StandardError => e
    context.fail!(error: e.message)
  end

  private

  def find_subscription(subscription_id)
    subscription_record = Subscription.find_by(stripe_subscription_id: subscription_id)
    context.fail!(error: 'Subscription not found or not paid') unless subscription_record&.paid?
    subscription_record
  end

  def cancel_subscription(subscription_record)
    if subscription_record.may_cancel?
      subscription_record.cancel!
    else
      context.fail!(error: 'Subscription cannot be canceled')
    end
  end
end
