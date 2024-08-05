# frozen_string_literal: true

RSpec.describe 'Stripe Webhooks', type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe 'POST /stripe_webhook' do
    let(:event_type) { 'customer.subscription.created' }
    let(:event) { StripeMock.mock_webhook_event(event_type) }
    let(:payload) { event.to_json }
    let(:sig_header) { generate_stripe_signature(payload) }

    it 'responds with success' do
      post '/stripe_webhook', params: payload, headers: { 'Stripe-Signature' => sig_header }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Success')
    end

    it 'enqueues the DispatchStripeEventJob' do
      expect do
        post '/stripe_webhook', params: payload, headers: { 'Stripe-Signature' => sig_header }
      end.to have_enqueued_job(DispatchStripeEventJob)
    end

    context 'with invalid payload' do
      let(:invalid_payload) { 'invalid_payload' }
      let(:invalid_sig_header) { generate_stripe_signature(invalid_payload) }

      it 'responds with bad request' do
        post '/stripe_webhook', params: invalid_payload, headers: { 'Stripe-Signature' => invalid_sig_header }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Invalid payload')
      end
    end

    context 'with invalid signature' do
      let(:invalid_sig_header) { 'invalid_signature' }

      it 'responds with bad request' do
        post '/stripe_webhook', params: payload, headers: { 'Stripe-Signature' => invalid_sig_header }
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Invalid signature')
      end
    end
  end
end
