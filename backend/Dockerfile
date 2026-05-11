FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --production
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download Moyasar SDK files locally to avoid CDN blocking
RUN mkdir -p public/static && \
    curl -sL -o public/static/moyasar.css https://unpkg.com/moyasar-payment-form@2.2.7/dist/moyasar.css && \
    curl -sL -o public/static/moyasar.js https://unpkg.com/moyasar-payment-form@2.2.7/dist/moyasar.umd.min.js

COPY . .
EXPOSE 5000
CMD ["npm", "start"]
