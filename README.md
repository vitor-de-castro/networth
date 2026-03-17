# 💰 NetWorth - Personal Portfolio Tracker

A full-stack Rails application for tracking and analyzing your personal net worth with real-time market data, AI-powered financial insights, and multi-currency support.

**Live Demo:** [networth.cv](https://networth.cv)

## 🎯 Key Features

### Portfolio Management
- **Asset Tracking** - Manage all your assets: stocks, crypto, property, vehicles, and more
- **Live Market Data** - Real-time prices for stocks and cryptocurrencies
- **Multi-Currency Support** - Track assets in USD, EUR, GBP, JPY, CHF, CAD, AUD
- **Smart Tracking** - Choose between manual values or live price tracking per asset

### Analytics & Insights
- **Interactive Charts** - Visual breakdown of your portfolio with pie charts and category analysis
- **Net Worth History** - Track your wealth growth over time with 30-day historical data
- **AI Financial Assistant** - Get personalized portfolio advice powered by OpenAI GPT-3.5
- **Quick Stats Dashboard** - See your biggest asset, portfolio diversity, and allocation at a glance

### Productivity Features
- **Bulk Stock Import** - Add multiple stocks at once (perfect for eToro users)
- **Live Market Widget** - Monitor S&P 500, NASDAQ, Bitcoin, Ethereum, Gold, and Silver
- **Responsive Design** - Seamless experience on desktop, tablet, and mobile

---

## 🛠️ Tech Stack

### Backend
- **Ruby on Rails 7** - Full-stack framework with Turbo for reactive UI
- **PostgreSQL** - Relational database for data persistence
- **Devise** - Authentication and user management

### Frontend
- **SCSS** - Custom styling with modular architecture
- **Chart.js + Chartkick** - Data visualization
- **Lucide Icons** - Modern iconography
- **Turbo Streams** - Real-time AI chat updates

### External APIs
- **Yahoo Finance API** - Real-time stock prices
- **CoinGecko API** - Cryptocurrency and commodity prices
- **ExchangeRate API** - Live currency conversion rates
- **OpenAI API** - GPT-3.5 for financial insights

### Deployment
- **Heroku** - Hosted on EU region
- **Custom Domain** - SSL-enabled at networth.cv
- **Environment Variables** - Secure API key management

---

## 🚀 Getting Started

### Prerequisites
- Ruby 3.x
- Rails 7.1.6
- PostgreSQL
- Node.js (for asset compilation)

## 💡 How It Works

### Live Asset Tracking

Assets can be tracked in two modes:

**Manual Mode** - Perfect for assets without live prices (property, vehicles):
```ruby
Asset: "My House"
Category: Property
Value: €300,000
```

**Live Tracking Mode** - For stocks and crypto with real-time prices:
```ruby
Asset: "Bitcoin Investment"
Category: Crypto
Symbol: BTC
Quantity: 1.5
Value: Auto-calculated from live price
```

### Currency Conversion

All assets are stored in EUR and converted for display:
```ruby
# Stored value: €100,000
# User currency: USD
# Displayed: $109,000 (using live exchange rate)
```

### API Caching

Market data is cached to handle API failures gracefully:
- Live price fetched → Cached for future use
- API fails → Shows last known price
- No cache → Shows "Temporarily unavailable"

---

## 📊 Architecture Highlights

### Service Objects
```ruby
# Clean separation of concerns
MarketDataService.fetch_all
ExchangeRateService.get_usd_to_eur_rate
MarketDataCache.get("stock_AAPL")
```

### Model Callbacks
```ruby
# Automatic net worth snapshots
before_validation :set_live_value
after_commit :create_net_worth_snapshot
```

### Database Design
- User → has_many Assets
- User → has_many NetWorthSnapshots
- Unique index on [user_id, date] for snapshots
- Decimal precision for accurate financial data

---

## 🎨 Design Philosophy

- **Mobile-First** - Optimized for all screen sizes
- **No UI Framework** - Custom SCSS for full control
- **Glassmorphism** - Modern card designs with subtle transparency
- **Accessibility** - Semantic HTML and ARIA labels

---

## 🔐 Security

- Devise authentication with secure password hashing
- CSRF protection on all forms
- Environment variables for API keys
- Database-level validations
- Production error pages (no stack traces exposed)

---

## 👤 Author

**Vitor de Castro**
- Portfolio: https://vitor-de-castro.github.io/
- LinkedIn: https://www.linkedin.com/in/vitor-castro-a279b8151/
- GitHub: https://github.com/vitor-de-castro
