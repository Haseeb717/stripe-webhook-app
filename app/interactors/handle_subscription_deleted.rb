# frozen_string_literal: true

# Interactor to handle the deletion of a subscription event from Stripe.
class HandleSubscriptionDeleted
  include Interactor

  def call
    subscription = context.event.data.object
    subscription_record = Subscription.find_by(stripe_subscription_id: subscription.id)

    if subscription_record
      cancel_subscription(subscription_record)
    else
      context.fail!(error: 'Subscription not found')
    end
  end

  private

  def cancel_subscription(subscription_record)
    if subscription_record.may_cancel?
      subscription_record.cancel!
    else
      context.fail!(error: 'Subscription cannot be canceled')
    end
  end
end
