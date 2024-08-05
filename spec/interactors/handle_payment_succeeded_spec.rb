# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HandlePaymentSucceeded, type: :interactor do
  let(:subscription) { create(:subscription, status:) }
  let(:status) { 'unpaid' }
  let(:event) do
    StripeMock.mock_webhook_event('invoice.payment_succeeded', subscription: subscription.stripe_subscription_id)
  end

  before do
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  describe '.call' do
    context 'when the subscription is found and can be marked as paid' do
      it 'marks the subscription as paid' do
        result = HandlePaymentSucceeded.call(event:)
        expect(result).to be_success
      end
    end

    context 'when the subscription is not found' do
      before do
        allow(Subscription).to receive(:find_by).and_return(nil)
      end

      it 'fails with a subscription not found error' do
        result = HandlePaymentSucceeded.call(event:)
        expect(result).to be_failure
        expect(result.error).to eq('Subscription not found')
      end
    end

    context 'when the subscription cannot be marked as paid' do
      let(:status) { 'paid' }

      it 'fails with an error indicating the subscription cannot be marked as paid' do
        result = HandlePaymentSucceeded.call(event:)
        expect(result).to be_failure
        expect(result.error).to eq('Subscription cannot be marked as paid')
      end
    end
  end
end
