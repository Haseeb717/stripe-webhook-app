# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DispatchStripeEventJob, type: :job do
  include ActiveJob::TestHelper

  let(:event) { StripeMock.mock_webhook_event('customer.subscription.created') }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#perform' do
    context 'when DispatchStripeEvent interactor succeeds' do
      before do
        allow(DispatchStripeEvent).to receive(:call).with(event:).and_return(double(success?: true))
      end

      it 'processes the event successfully' do
        expect do
          perform_enqueued_jobs do
            DispatchStripeEventJob.perform_now(event)
          end
        end.not_to raise_error
      end
    end
  end
end
