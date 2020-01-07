using AWSCore
using XMLDict
using JSON

aws = aws_config()

struct Service
    request::Function
    service_name::String
    api_version::String
    service_endpoint::String
end

function rest_xml(service::Service, request_method::String, request_uri::String, args...)
    AWSCore.service_rest_xml(
        aws;
        service=service.service_name,
        version=service.api_version,
        verb=request_method,
        resource=request_uri,
        args=args
    )
end

function parse_metadata()
    return JSON.parsefile("metadata.json")
end

function service(service_name::String)
    service = metadata[service_name]

    request_function = getfield(Main, Symbol(service["protocol"]))
    api_version = service["api_version"]

    service_endpoint = ""

    if haskey(service, "endpoint")
        service_endpoint = service["endpoint"]
    end

    return Service(request_function, service_name, api_version, service_endpoint)
end

function main()
    global metadata = parse_metadata()
    s3 = service("s3")

    buckets = s3.request(s3, "GET", "/")["Buckets"].x
    buckets = xml_dict(parse_xml(string(buckets)))

    println(json(buckets, 4))
end

main()
