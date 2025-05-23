FROM node:20-alpine AS base

FROM base AS deps
WORKDIR /app

COPY package.json package-lock.json ./ 

RUN npm ci 

COPY . . 


FROM base AS builder 
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules 
COPY . .

ENV PATH /app/node_modules/.bin:$PATH

RUN npm run build 

FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

EXPOSE 3000 

RUN addgroup --system --gid 1001 nodejs 
RUN adduser --system --uid 1001 nextjs 
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/public ./public 
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static 


USER nextjs

CMD ["node", "server.js"]

