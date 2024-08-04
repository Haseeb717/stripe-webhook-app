# frozen_string_literal: true

# Interactor to dispatch Stripe events to the appropriate handlers.
class DispatchStripeEvent
  include Interactor

  LOCK_EXPIRY_TIME = 10.minutes

  before do
    @event_id = context.event.id
    @lock_key = "stripe_event:#{@event_id}"

    context.fail!(error: 'Event type not supported') unless handler_for(context.event)
    context.fail!(error: 'Event is already being processed') unless acquire_lock(@lock_key)
  end

  def call
    handler = handler_for(context.event)
    result = handler.call(event: context.event)

    context.fail!(error: result.error) unless result.success?
  ensure
    release_lock(@lock_key)
  end

  private

  def acquire_lock(key)
    Redis.current.set(key, true, nx: true, ex: LOCK_EXPIRY_TIME)
  end

  def release_lock(key)
    Redis.current.del(key)
  end

  def handler_for(event)
    case event.type
    when 'customer.subscription.created'
      HandleSubscriptionCreated
    when 'invoice.payment_succeeded'
      HandlePaymentSucceeded
    when 'customer.subscription.deleted'
      HandleSubscriptionDeleted
    end
  end
end
