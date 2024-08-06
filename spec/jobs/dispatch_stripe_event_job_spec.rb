# frozen_string_literal: true

# spec/jobs/dispatch_stripe_event_job_spec.rb

require 'rails_helper'

RSpec.describe DispatchStripeEventJob, type: :job do
  include ActiveJob::TestHelper

  let(:event) { StripeMock.mock_webhook_event('invoice.payment_succeeded') }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#perform' do
    context 'when DispatchStripeEvent interactor succeeds' do
      before do
        allow(DispatchStripeEvent).to receive(:call).with(event: event.as_json).and_return(double(success?: true))
      end

      it 'processes the event successfully' do
        expect do
          perform_enqueued_jobs do
            DispatchStripeEventJob.perform_now(event.as_json)
          end
        end.not_to raise_error
      end
    end

    context 'when DispatchStripeEvent interactor fails with a SubscriptionNotFoundError' do
      before do
        allow(DispatchStripeEvent).to receive(:call).with(event: event.as_json)
                                                    .and_return(double(success?: false,
                                                                       error: 'Subscription not found'))
      end

      it 'raises SubscriptionNotFoundError and retries the job' do
        DispatchStripeEventJob.perform_later(event.as_json)

        perform_enqueued_jobs do
          expect do
            DispatchStripeEventJob.perform_now(event.as_json)
          end.to raise_error(SubscriptionNotFoundError)
        end

        expect(enqueued_jobs.size).to eq(1)
      end
    end

    context 'when DispatchStripeEvent interactor fails with other errors' do
      before do
        allow(DispatchStripeEvent).to receive(:call).with(event: event.as_json)
                                                    .and_return(double(success?: false,
                                                                       error: 'Some other error'))
      end

      it 'raises StandardError for other errors' do
        DispatchStripeEventJob.perform_later(event.as_json)

        perform_enqueued_jobs do
          expect do
            DispatchStripeEventJob.perform_now(event.as_json)
          end.to raise_error(StandardError)
        end
      end
    end
  end
end
