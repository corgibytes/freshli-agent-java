require 'rspec/expectations'

require 'freshli_agent_services_pb'
require 'health_services_pb'

class GrpcClient
  include RSpec::Matchers

  def initialize(port)
    @port = port
  end

  def shutdown!
    client = grpc_agent_client_on(@port)
    response = client.shutdown(::Google::Protobuf::Empty.new)
    expect(response).to be_a(::Google::Protobuf::Empty)
  end

  def detect_manifests(project_path)
    client = grpc_agent_client_on(@captured_port)
    response = client.detect_manifests(::Com::Corgibytes::Freshli::Agent::ProjectLocation.new(path: project_path))

    result = []
    response.each do |location|
      result << location.path
    end
    result
  end

  def get_validating_packages
    client = grpc_agent_client_on(@port)
    response = client.get_validating_packages(::Google::Protobuf::Empty.new)

    result = []
    response.each do |package|
      result << package.purl
    end
    result
  end

  def health_check
    client = Grpc::Health::V1::Health::Stub.new("localhost:#{@port}", :this_channel_is_insecure)
    response = client.check(Grpc::Health::V1::HealthCheckRequest.new(service: Com::Corgibytes::Freshli::Agent::Agent::Service.service_name))
    response.status
  end

  def is_running!
    expect(health_check).to eq(:SERVING)
  end

  private
  def grpc_agent_client_on(port)
    Com::Corgibytes::Freshli::Agent::Agent::Stub.new("localhost:#{@port}", :this_channel_is_insecure)
  end

end
