# Use the official Node.js image as the base image
FROM node:16-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy the entire project to the container
COPY . .

# Expose the port your Node.js app is listening on
EXPOSE 3000

# Command to start your Node.js app
CMD ["npm", "start"]
