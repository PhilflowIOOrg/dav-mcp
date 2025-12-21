FROM node:25-alpine

WORKDIR /app

# Install git and CA certificates for compatibility with previous image
RUN apk add --no-cache git ca-certificates

# Copy package files
COPY package*.json ./

# Install dependencies
RUN rm -f package-lock.json && \
    npm install --production --no-audit --no-fund && \
    npm cache clean --force

# Copy source code
COPY src ./src

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Start server
CMD ["node", "src/index.js"]
