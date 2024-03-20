

resource "aws_cloudfront_distribution" "cloudfront_subdomain" {
  
  enabled = true
  aliases = ["www.ntcloudresume.com"]
  default_root_object = "index.html"
  
  origin {
    origin_id                = "www.ntcloudresume.com.s3.us-east-1.amazonaws.com"
    domain_name              = "www.ntcloudresume.com.s3.us-east-1.amazonaws.com"
     
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_subdomain_origin_access.cloudfront_access_identity_path
    }

  }

  default_cache_behavior {
    
    target_origin_id = "www.ntcloudresume.com.s3.us-east-1.amazonaws.com"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id  = aws_cloudfront_cache_policy.cloudfront_cache_policy.id

    # forwarded_values {
    #  query_string = true
    #   cookies {
    #    forward = "all"
    #  }
    #}
   

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
    restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }
  
  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.acm_cert.arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version ="TLSv1.2_2021"
  }
#limiting my cloudfront to certain areas
  price_class = "PriceClass_100"
  
}


resource "aws_cloudfront_origin_access_identity" "cloudfront_subdomain_origin_access" {
comment = "www.ntcloudresume.s3.us-east-1.amazonaws.com"
    
}



#Create Caching Policy

resource "aws_cloudfront_cache_policy" "cloudfront_cache_policy" {
  name        = "Caching-Disabled"
  min_ttl     = 0
  max_ttl = 0
  default_ttl =0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

#Distrubition for Root Domain

resource "aws_cloudfront_distribution" "cloudfront_rootdomain" {
  
  enabled = true
  aliases = ["ntcloudresume.com"]
  
  origin {
    origin_id                = "ntcloudresume.com.s3-website-us-east-1.amazonaws.com"
    domain_name              = "ntcloudresume.com.s3.us-east-1.amazonaws.com"
     
  }

  default_cache_behavior {
    
    target_origin_id = "ntcloudresume.com.s3-website-us-east-1.amazonaws.com"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    cache_policy_id  = aws_cloudfront_cache_policy.cloudfront_cache_policy.id

    # forwarded_values {
    #  query_string = true
    #   cookies {
    #    forward = "all"
    #  }
    #}
   

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
    restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }
  
  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.acm_cert.arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version ="TLSv1.2_2021"
  }
#limiting my cloudfront to certain areas
  price_class = "PriceClass_100"
  
}
