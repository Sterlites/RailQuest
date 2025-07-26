# Dockerfile
# Production-ready Docker configuration
FROM ruby:3.2.0-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      libpq-dev \
      libvips \
      pkg-config \
      curl \
      nodejs \
      npm && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install JavaScript dependencies
RUN yarn install --frozen-lockfile --production

# Copy application code
COPY . .

# Precompile assets
RUN RAILS_ENV=production \
    SECRET_KEY_BASE=dummy \
    bundle exec rails assets:precompile

# Create non-root user
RUN groupadd -r rails && useradd -r -g rails rails
RUN chown -R rails:rails /app
USER rails

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]