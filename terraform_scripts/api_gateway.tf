
#Creating REST API name and endpoint_configuration

resource "aws_api_gateway_rest_api" "api_counter" {
  name = "visitor_counter"
  description = "Visitor counter API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


#API Gateway Resource

resource "aws_api_gateway_resource" "api_counter_gateway" {
  rest_api_id = aws_api_gateway_rest_api.api_counter.id
  parent_id   = aws_api_gateway_rest_api.api_counter.root_resource_id
  path_part   = "main"
}

#Enabling CORS
Need to enable CORS later on


#Defining the integration to lambda for GET

resource "aws_api_gateway_integration" "api_counter_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.api_counter.id
  resource_id             = aws_api_gateway_resource.api_counter_gateway.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.test_lambda.invoke_arn


}

#Defining the integration to lambda for POST
/*
resource "aws_api_gateway_integration" "api_counter_integration_post" {
  rest_api_id             = aws_api_gateway_rest_api.api_counter.id
  resource_id             = aws_api_gateway_resource.api_counter_gateway.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
  passthrough_behavior      = "WHEN_NO_TEMPLATES"

}
*/

#Defining the GET method

resource "aws_api_gateway_method" "api_counter_method_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_counter.id
  resource_id   = aws_api_gateway_resource.api_counter_gateway.id
  http_method   = "GET"
  authorization = "NONE"
}

#Defining the POST method
/*
resource "aws_api_gateway_method" "api_counter_method_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_counter.id
  resource_id   = aws_api_gateway_resource.api_counter_gateway.id
  http_method   = "POST"
  authorization = "NONE"
}
*/

#Integration Response for GET & POST


resource "aws_api_gateway_integration_response" "api_counter_response_get_200" {
  rest_api_id = aws_api_gateway_rest_api.api_counter.id
  resource_id = aws_api_gateway_resource.api_counter_gateway.id
  http_method = aws_api_gateway_method.api_counter_method_get.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.api_counter_integration_get
  ]
}

/*
resource "aws_api_gateway_integration_response" "api_counter_response_post_200" {
  rest_api_id = aws_api_gateway_rest_api.api_counter.id
  resource_id = aws_api_gateway_resource.api_counter_gateway.id
  http_method = aws_api_gateway_method.api_counter_method_post.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.api_counter_integration_post
  ]

response_templates = {
       "application/json" = ""
   } 

}
*/
#API Gateway Method Response

resource "aws_api_gateway_method_response" "api_counter_response_method_get" {
  rest_api_id = aws_api_gateway_rest_api.api_counter.id
  resource_id = aws_api_gateway_resource.api_counter_gateway.id
  http_method = aws_api_gateway_method.api_counter_method_get.http_method
  status_code = "200"

}
/*
resource "aws_api_gateway_method_response" "api_counter_response_method_post" {
  rest_api_id = aws_api_gateway_rest_api.api_counter.id
  resource_id = aws_api_gateway_resource.api_counter_gateway.id
  http_method = aws_api_gateway_method.api_counter_method_post.http_method
  status_code = "200"

   response_models = {
     "application/json" = "Empty"
  }


}
  */
#Granting permissions for API Gateway to interact with Lambda

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_function_name"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_rest_api.api_counter.execution_arn}/*"
}

#Creating Stage for Deployment

resource "aws_api_gateway_stage" "api_counter_stage" {
  deployment_id = aws_api_gateway_deployment.api_counter_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_counter.id
  stage_name    = "DEV"

}

#API Deployment

resource "aws_api_gateway_deployment" "api_counter_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_counter.id
    lifecycle {
    create_before_destroy = true
  }

#Deployment can not start until methods and integrations are live

 depends_on = [
    aws_api_gateway_method.api_counter_method_get,
   # aws_api_gateway_method.api_counter_method_post,
    aws_api_gateway_integration.api_counter_integration_get,
    #aws_api_gateway_integration.api_counter_integration_post
  ]

}


#Permissions for Lambda to invoke API

data "aws_iam_policy_document" "api_counter_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = [format("%s/%s",aws_api_gateway_rest_api.api_counter.execution_arn,"*/GET/main")]

  }
}
resource "aws_api_gateway_rest_api_policy" "api_counter_policy" {
  rest_api_id = aws_api_gateway_rest_api.api_counter.id
  policy      = data.aws_iam_policy_document.api_counter_policy_doc.json
}