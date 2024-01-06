# Use the official Ubuntu image
FROM ubuntu:20.04

# Avoid interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists
RUN apt-get update -y

# Install essential dependencies
RUN apt-get install -y build-essential libpq-dev postgresql-client nodejs npm curl

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Set the working directory inside the container
WORKDIR /app

# Copy Gemfile and Gemfile.lock and install gems
COPY Gemfile Gemfile.lock /app/

# Copy the rest of the application code
COPY . /app/

# Install Node using NVM
SHELL ["/bin/bash", "-c"]
RUN source /root/.nvm/nvm.sh && nvm install stable && nvm alias default stable


# Install Yarn
RUN npm install -g yarn

# Install Ruby 2.4.2 using rbenv
RUN apt-get install -y git libssl-dev libreadline-dev zlib1g-dev
RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init --no-rehash -)"' >> ~/.bashrc
RUN exec bash
RUN rbenv install 2.4.2
RUN rbenv global 2.4.2

# Set environment variables
ENV PATH="/root/.rbenv/shims:${PATH}"

# Install Bundler
RUN gem install bundler -v 2.2.29
RUN bundle install

# Create and migrate the database
RUN bundle exec rake db:create db:migrate

# Expose port 5100
EXPOSE 5100

# Start the application
CMD ["foreman", "start", "-m", "gulp=1,worker=1,release=0,web=1"]
