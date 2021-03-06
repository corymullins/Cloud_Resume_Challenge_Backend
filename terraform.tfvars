frontend_bucket_name        = "www.corymullins.com"
terraform_state_bucket_name = "corymullins-terraform"
domain_name                 = "corymullins.com"
endpoint                    = "www.corymullins.com"
table_name                  = "cloud_resume_stats"
hash_key                    = "view-count"
type                        = "N"
lambda_name                 = "resume_counter"
header                      = "https://www.corymullins.com"
api_name                    = "cloud_resume_challenge"
lambda_uri                  = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:659937165493:function:resume_counter/invocations"