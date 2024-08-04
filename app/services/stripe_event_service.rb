# frozen_string_literal: true

# Service class to handle Stripe events.
class StripeEventService
  def self.construct_event(payload, sig_header)
    Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_WEBHOOK_KEY'])
  rescue JSON::ParserError
    raise InvalidPayloadError, 'Invalid payload'
  rescue Stripe::SignatureVerificationError
    raise InvalidSignatureError, 'Invalid signature'
  end

  class InvalidPayloadError < StandardError; end
  class InvalidSignatureError < StandardError; end
end
