FROM node:24-alpine

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

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"

# Start server (HTTP mode for Docker/remote deployments)
CMD ["node", "src/server-http.js"]
