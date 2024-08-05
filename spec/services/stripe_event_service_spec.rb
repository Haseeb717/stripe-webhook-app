# frozen_string_literal: true

RSpec.describe StripeEventService, type: :service do
  let(:event) { StripeMock.mock_webhook_event('customer.subscription.created') }
  let(:payload) { event.to_json }
  let(:sig_header) { generate_stripe_signature(payload) }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe '.construct_event' do
    context 'with valid payload and signature' do
      it 'constructs a Stripe event successfully' do
        result = StripeEventService.construct_event(payload, sig_header)
        expect(result).to be_a(Stripe::Event)
        expect(result.id).to eq(event.id)
      end
    end

    context 'with invalid payload' do
      let(:invalid_payload) { 'invalid_payload' }
      let(:invalid_sig_header) { generate_stripe_signature(invalid_payload) }

      it 'raises InvalidPayloadError' do
        expect do
          StripeEventService.construct_event(invalid_payload, invalid_sig_header)
        end.to raise_error(StripeEventService::InvalidPayloadError, 'Invalid payload')
      end
    end

    context 'with invalid signature' do
      let(:invalid_sig_header) { 'invalid_signature' }

      it 'raises InvalidSignatureError' do
        expect do
          StripeEventService.construct_event(payload, invalid_sig_header)
        end.to raise_error(StripeEventService::InvalidSignatureError, 'Invalid signature')
      end
    end
  end
end
