# frozen_string_literal: true

# Controller to handle incoming Stripe webhook events.
class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = StripeEventService.construct_event(payload, sig_header)
    rescue StripeEventService::InvalidPayloadError, StripeEventService::InvalidSignatureError => e
      render_error(e.message)
      return
    end

    DispatchStripeEventJob.perform_later(event)
    render json: { message: 'Success' }, status: :ok
  end

  private

  def render_error(message)
    render json: { error: message }, status: :bad_request
  end
end
