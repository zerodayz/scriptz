# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Start from the latest golang base image
FROM golang:latest

# Add Maintainer Info
LABEL maintainer="Robin Cernin <cerninr@gmail.com>"

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the source from the current directory to the Working Directory inside the container
RUN curl -SL https://raw.githubusercontent.com/zerodayz/kubernetes/master/readyz/readyz.go -o readyz.go

# Build the Go app
RUN go build -o readyz .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./readyz"]
