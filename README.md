# Stripe Webhook App

Description
This Rails application is designed to handle subscription lifecycle events from Stripe. It automatically updates local subscription records based on Stripe webhook events such as creation, payment, and cancellation.

### Features
- **Subscription Creation**: Automatically creates a subscription record in the local database with an initial status of 'unpaid' when a new subscription is created in Stripe.
- **Invoice Payment**: Updates the local subscription record status to 'paid' when the first invoice is paid.
- **Subscription Cancellation**: Changes the local subscription record status to 'canceled' when a subscription is canceled in Stripe, but only if the subscription was previously 'paid'.

### Prerequisites
- Ruby 3.2.2: Ensure that Ruby version 3.2.2 is installed on your system.
- PostgreSQL: Verify that PostgreSQL is installed and operational.
- Stripe Account: Create a free [Stripe account](https://dashboard.stripe.com/register) if you don't already have one.
- Stripe CLI: Install the [Stripe CLI](https://stripe.com/docs/stripe-cli) for local webhook testing.

## Setup Instructions
### 1. Clone the Repository
```sh
git clone https://github.com/Haseeb717/stripe-webhook-app.git
cd stripe-webhook-app
```

### 2. Install Dependencies
```sh
bundle install
```

### 3. Database configuration
```sh
rails db:create
rails db:migrate
```

### 4. Stripe CLI and webhook listen
Login to stripe-cli

```sh
stripe login
```
Ensure these events are forwarded to your local server using Stripe CLI:

```sh
stripe listen --events customer.subscription.created,invoice.payment_succeeded,customer.subscription.deleted --forward-to localhost:3000/stripe_webhook
```

You can add other events also in above command as per requirement.

### 5. Configure Environment Variables
Copy the example environment variables file and edit it with your Stripe credentials:

```sh
cp .env.example .env
```
Edit .env with your Stripe keys:

**STRIPE_SECRET_KEY**: Your Stripe secret key. You can get it from api-keys on [Stripe dashboard](https://dashboard.stripe.com/apikeys)

**STRIPE_WEBHOOK_KEY**: Obtain this by running ```sh stripe listen --forward-to localhost:3000/stripe_webhook```. For production or staging we can get this key from [Stripe dashboard](https://dashboard.stripe.com/webhooks) as per endpoint registered.

### 6. Run Tests

Execute the test suite:

```sh 
bundle exec rspec
```

### 7. Rails Server

Run the rails server on console with port 3000:

```sh
rails s -p 3000
```

Editing stripe-webhook-app/README.md at main · Haseeb717/stripe-webhook-app

