using AWSCore
using XMLDict
using JSON
using LazyJSON
using SymDict

struct REST_XML_Operation
    name::String
    method::String
    request_uri::String
end

struct Client__Rest_XML
    credentials
    service_name::String
    api_version::String
    endpoint::String

    operations::Array{REST_XML_Operation}
end

function Base.println(operations::Array{REST_XML_Operation})
    for op in operations
        println(op.name, " ", op.method, " ", op.request_uri)
    end
end

function create_client(service_name::String)
    service_data = LazyJSON.parse(String(read("data/$(service_name).json")))
    metadata = service_data["metadata"]
    operations = service_data["operations"]

    protocol = metadata["protocol"]

    if protocol == "rest-xml"
        return _create_rest_xml_client(metadata, operations)
    end
end

function _create_rest_xml_client(metadata::LazyJSON.Object, operations::LazyJSON.Object)
    available_operations = Array{REST_XML_Operation, 1}()

    for operation in operations
        http = operation[2]["http"]  # Get the HTTP endpoint description of the operation

        op = REST_XML_Operation(
            operation[1],  # Name of the operation
            http["method"],
            http["requestUri"]
        )

        push!(available_operations, op)
    end

    return Client__Rest_XML(
        AWSCore.default_aws_config(),
        lowercase(metadata["serviceId"]),
        metadata["apiVersion"],
        metadata["globalEndpoint"],
        available_operations
    )
end

function describe_operations(client::Client__Rest_XML)
    println(json([op.name for op in client.operations], 2))
end

function describe_operation(client::Client__Rest_XML, operation::String)
    println(filter(op->op.name == operation, client.operations))
end

function request(client::Client__Rest_XML, request_method::String, request_uri::String, args=[])
    return AWSCore.service_rest_xml(
        client.credentials;
        service=client.service_name,
        version=client.api_version,
        verb=request_method,
        resource=request_uri,
        args=args
    )
end

function main()
    s3 = create_client("s3")
    describe_operations(s3)
    describe_operation(s3, "ListBuckets")

    request(s3, "PUT", "/hi-this-will-only-work-once")

    req = request(s3, "GET", "/")
    buckets = xml_dict(parse_xml(string(req["Buckets"].x)))
    println(json(buckets, 4))
end

main()
