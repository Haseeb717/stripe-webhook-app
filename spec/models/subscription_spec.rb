# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'validations' do
    before do
      # Create a record with a known stripe_subscription_id
      create(:subscription, stripe_subscription_id: 'unique_id')
    end

    it { should validate_presence_of(:stripe_subscription_id) }
    it { should validate_uniqueness_of(:stripe_subscription_id) }
    it { should validate_presence_of(:status) }
  end

  describe 'state transitions' do
    let(:subscription) { create(:subscription, status: 'unpaid') }

    context 'when marking as paid' do
      it 'transitions from unpaid to paid' do
        expect(subscription.may_pay?).to be true
        subscription.pay!
        expect(subscription.status).to eq('paid')
      end
    end

    context 'when canceling' do
      before { subscription.update(status: 'paid') }

      it 'transitions from paid to canceled' do
        expect(subscription.may_cancel?).to be true
        subscription.cancel!
        expect(subscription.status).to eq('canceled')
      end

      it 'does not allow canceling from unpaid' do
        subscription.update(status: 'unpaid')
        expect(subscription.may_cancel?).to be false
      end
    end
  end
end
