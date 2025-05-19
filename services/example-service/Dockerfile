FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# TODO: Add any service-specific build steps here
# TODO: Consider multi-stage builds for production optimization

# Expose the service port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --spider -q http://localhost:3000/health || exit 1

# Start the service
CMD ["node", "src/index.js"]