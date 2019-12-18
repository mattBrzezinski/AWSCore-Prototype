module AWSCorePrototype

using XMLDict

include("S3/S3.jl")

export Endpoint

bucket_result = S3.list_buckets()["Buckets"].x
last_bucket = parse_xml(string(bucket_result.lastelement))
bucket_name = Dict(last_bucket)["Name"]

objects_result = S3.list_objects(bucket_name)

for object in Dict(objects_result)["Contents"]
    println(object["Key"])
end

end  # End Module
