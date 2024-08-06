# frozen_string_literal: true

# Job to dispatch Stripe events to the appropriate handlers.
class DispatchStripeEventJob < ApplicationJob
  queue_as :default

  retry_on SubscriptionNotFoundError, wait: :exponentially_longer, attempts: 2

  def perform(event)
    result = DispatchStripeEvent.call(event:)

    return if result.success?

    raise SubscriptionNotFoundError, result.error if result.error == 'Subscription not found'

    raise StandardError, result.error
  end
end
