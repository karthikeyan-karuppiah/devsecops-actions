FROM alpine:3.21.3

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD pgrep -x sleep || exit 1

CMD ["sleep", "infinity"]
