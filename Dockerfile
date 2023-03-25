# Use Node.js 14 alpine as the base image
FROM node:14-alpine
# Creating Directory in Base image
RUN mkdir /app
# Set the working directory to /app
WORKDIR /app

COPY . .

# Run npm init and install express
RUN npm init -y

# Expose port 3000
EXPOSE 3000

# Run the application
CMD ["node", "/app/examples/hello-world/index.js"]
