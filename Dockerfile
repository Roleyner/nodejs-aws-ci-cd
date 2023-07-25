# Use the official Python image as the base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Python application code to the container
COPY app.py .

# Expose port 80 to listen for incoming requests
EXPOSE 80

# Define the command to run the Flask application
CMD ["python", "app.py"]
