# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HandleSubscriptionDeleted, type: :interactor do
  let(:status) { 'paid' }
  let(:subscription) { create(:subscription, status:) }
  let(:event) do
    StripeMock.mock_webhook_event(
      'customer.subscription.deleted',
      {
        id: subscription.stripe_subscription_id
      }
    )
  end

  before do
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  describe '.call' do
    context 'when the subscription is found and can be canceled' do
      it 'cancels the subscription' do
        result = HandleSubscriptionDeleted.call(event:)
        expect(result).to be_success
      end
    end

    context 'when the subscription is not found' do
      before do
        allow(Subscription).to receive(:find_by).and_return(nil)
      end

      it 'fails with a subscription not found error' do
        result = HandleSubscriptionDeleted.call(event:)
        expect(result).to be_failure
        expect(result.error).to eq('Subscription not found')
      end
    end
  end
end
