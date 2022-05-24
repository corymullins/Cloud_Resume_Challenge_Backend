# Cloud_Resume_Challenge_Backend
CI/CD for backend of Cloud Resume Challenge.

Cloud Resume Challenge is a static website deployed from an AWS S3 bucket via CloudFront and Route 53. The visitor counter API is a serverless deployment of a Python Lambda function which updates a DynamoDB database, and controlled through API Gateway. The infrastructure, both frontend and backend, are automated with Terraform. Version control is handled by GitHub, and GitHub Actions is used to handle the CI/CD pipeline. A final end-to-end test is run using Cypress, which verifies the status and type of response from the API.

[Summary of project](https://dev.to/corymullins/cloud-resume-challenge-summary-47do) and [Frontend repository](https://github.com/corymullins/Cloud_Resume_Challenge_Frontend)
