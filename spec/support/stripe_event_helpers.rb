# frozen_string_literal: true

# spec/support/stripe_event_helpers.rb
module StripeEventHelpers
  def generate_stripe_signature(payload)
    secret = ENV['STRIPE_WEBHOOK_KEY']
    time = Time.now
    signature = Stripe::Webhook::Signature.compute_signature(time, payload, secret)

    Stripe::Webhook::Signature.generate_header(
      time,
      signature,
      scheme: Stripe::Webhook::Signature::EXPECTED_SCHEME
    )
  end
end
