module Utils

export Protocol, Endpoint

@enum Protocol begin
    rest_xml = 1
    json = 2
end

struct Endpoint
    service::String
    protocol::Protocol
    global_endpoint::String
    api_version::String
end

end  # End Module