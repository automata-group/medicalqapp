FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --production
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
