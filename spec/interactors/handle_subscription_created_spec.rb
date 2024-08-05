# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HandleSubscriptionCreated, type: :interactor do
  let(:event) do
    StripeMock.mock_webhook_event('customer.subscription.created')
  end

  before do
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  describe '.call' do
    context 'when event is valid and subscription is successfully created or updated' do
      it 'creates or updates the subscription record' do
        expect do
          HandleSubscriptionCreated.call(event:)
        end.to change { Subscription.count }.by(1)

        result = HandleSubscriptionCreated.call(event:)
        expect(result).to be_success
      end
    end
  end
end
