# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DispatchStripeEvent, type: :interactor do
  let(:event) { StripeMock.mock_webhook_event('customer.subscription.created') }
  let(:handler) { instance_double('HandleSubscriptionCreated') }
  let(:lock_key) { "stripe_event:#{event.id}" }

  before do
    allow(Redis.current).to receive(:set).and_return(true)
    allow(Redis.current).to receive(:del).and_return(1)
    StripeMock.start
  end

  after do
    StripeMock.stop
  end

  describe '.call' do
    context 'when the event type is supported and lock is acquired' do
      before do
        allow_any_instance_of(DispatchStripeEvent).to receive(:handler_for)
          .and_return(HandleSubscriptionCreated)
        allow(HandleSubscriptionCreated).to receive(:call).and_return(double(success?: true))
        allow_any_instance_of(DispatchStripeEvent).to receive(:acquire_lock).and_return(true)
        allow_any_instance_of(DispatchStripeEvent).to receive(:release_lock).and_return(true)
      end

      it 'processes the event successfully' do
        result = DispatchStripeEvent.call(event:)
        expect(result).to be_success
      end
    end

    context 'when the event type is not supported' do
      before do
        allow_any_instance_of(DispatchStripeEvent).to receive(:handler_for)
          .and_return(nil)
      end

      it 'fails with an error message' do
        result = DispatchStripeEvent.call(event:)
        expect(result).to be_failure
        expect(result.error).to eq('Event type not supported')
      end
    end

    context 'when the event is already being processed' do
      before do
        allow_any_instance_of(DispatchStripeEvent).to receive(:acquire_lock).and_return(false)
      end

      it 'fails with an error message' do
        result = DispatchStripeEvent.call(event:)
        expect(result).to be_failure
        expect(result.error).to eq('Event is already being processed')
      end
    end

    context 'when the handler fails' do
      before do
        allow_any_instance_of(DispatchStripeEvent).to receive(:handler_for)
          .and_return(HandleSubscriptionCreated)
        allow(HandleSubscriptionCreated).to receive(:call).and_return(double(success?: false, error: 'Some error'))
        allow_any_instance_of(DispatchStripeEvent).to receive(:acquire_lock).and_return(true)
      end

      it 'fails with the error from the handler' do
        result = DispatchStripeEvent.call(event:)
        expect(result).to be_failure
        expect(result.error).to eq('Some error')
      end
    end
  end
end
