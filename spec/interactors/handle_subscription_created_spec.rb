# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HandleSubscriptionCreated, type: :interactor do
  let(:subscription) { create(:subscription) }
  let(:event) do
    StripeMock.mock_webhook_event('customer.subscription.created',
                                  data: { object: { id: subscription.stripe_subscription_id,
                                                    customer: subscription.stripe_customer_id } })
  end
  let(:subscription_record) do
    Subscription.find_or_initialize_by(stripe_subscription_id: subscription.stripe_subscription_id)
  end

  before do
    allow(Subscription).to receive(:find_or_initialize_by).and_return(subscription_record)
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  describe '.call' do
    context 'when event is valid and subscription is successfully created or updated' do
      it 'creates or updates the subscription record' do
        expect(subscription_record).to receive(:update!).with(
          stripe_customer_id: event.data.object.customer,
          status: 'unpaid'
        )

        result = HandleSubscriptionCreated.call(event:)
        expect(result).to be_success
        expect(result.subscription_record).to eq(subscription_record)
      end
    end

    context 'when an error occurs while processing' do
      before do
        allow(subscription_record).to receive(:update!).and_raise(StandardError, 'Update failed')
      end

      it 'fails with an error message' do
        result = HandleSubscriptionCreated.call(event:)
        expect(result).to be_failure
        expect(result.error).to eq('Update failed')
      end
    end
  end
end
