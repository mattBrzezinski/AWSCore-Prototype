module S3

using AWSCore
include("../Utils.jl")

aws = aws_config()
endpoint = Utils.Endpoint("s3", Utils.rest_xml, "s3.amazonaws.com", "2006-03-01")

function list_buckets(args...)
    method = "GET"
    request_uri = "/"

    AWSCore.service_rest_xml(
        aws;
        service      = endpoint.service,
        version      = endpoint.api_version,
        verb         = method,
        resource     = request_uri,
        args         = args
    )
end

function list_objects(bucket, args...)
    method = "GET"
    request_uri = "/$bucket"

    AWSCore.service_rest_xml(
        aws;
        service      = endpoint.service,
        version      = endpoint.api_version,
        verb         = method,
        resource     = request_uri,
        args         = args
    )
end

end  # End Module