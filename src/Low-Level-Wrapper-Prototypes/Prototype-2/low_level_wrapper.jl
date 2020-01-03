import LazyJSON
using JSON

struct REST_XML_Operation
    name::String
    method::String
    request_uri::String
end

struct JSON_Operation
    name::String
    parameters::Array{String}
end

struct Client__Rest_XML
    service_name::String
    api_version::String
    endpoint::String

    operations::Array{REST_XML_Operation}
end

struct Client__JSON
    service_name::String
    api_version::String
    json_version::String

    operation::Array{JSON_Operation}
end

function create_client(service_name::String)
    service_data = LazyJSON.parse(String(read("data/$(service_name).json")))
    metadata = service_data["metadata"]
    operations = service_data["operations"]

    protocol = metadata["protocol"]

    if protocol == "rest-xml"
        return _create_rest_xml_client(metadata, operations)
    elseif protocol == "json"
        return _create_json_client(metadata, operations)
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
        metadata["serviceId"],
        metadata["apiVersion"],
        metadata["globalEndpoint"],
        available_operations
    )
end

function _create_json_client(metadata::LazyJSON.Object, operations::LazyJSON.Object)
    available_operations = Array{JSON_Operation, 1}()

    for operation in operations
        required_parameters = try operation[2]["input"]["required"] catch e "" end
        required_parameters = [required_parameters]

        op = JSON_Operation(
            operation[1],  # Name of the operation
            string.(required_parameters)
        )
        push!(available_operations, op)
    end

    return Client__JSON(
        metadata["serviceId"],
        metadata["apiVersion"],
        metadata["jsonVersion"],
        available_operations
    )
end

function request(client::Client__Rest_XML)
    println("rest_xml")
end

function request(client::Client__JSON)
    println("json")
end

function main()
    s3 = create_client("s3")
    ecr = create_client("ecr")

    println(json(s3, 4))
    println(json(ecr, 4))
end

main()
