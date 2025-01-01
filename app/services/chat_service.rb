require 'dotenv/load'
require 'httparty'

class ChatService
  BASE_URL = 'https://api.x.ai/v1/chat/completions'
  XAI_ROLES = %w(system user assistant)

  def initialize(query, system_content = '')
    @query = query
    @system_content = system_content
  end

  def call
    @response = make_request
    if @response.success?
      completion = JSON.parse(response.body)
      completion['choices'][0]['message']
    else
      raise "Request failed with status code #{@response.code}: #{@response.message}"
    end
  end

  protected

  def request_headers
    headers = {
      'Authorization' => "Bearer #{xai_api_key}",
      'Content-Type' => 'application/json'
    }
  end

  def payload
    {
      model: xai_model,
      messages: conversation + [current_query]
    }.to_json
  end

  def xai_api_key
    ENV['XAI_API_KEY']
  end

  def xai_model
    'grok-2-latest'
  end

  def conversation
    [
      { role: 'system', content: system_content },
      #{ role: 'user', content: user_content}
    ]
  end

  def user_content
    ''
  end

  def current_query
    { role: 'user', content: @query }
  end

  def system_content
    @system_content
  end

  def make_request
    response = HTTParty.post(BASE_URL,
                             headers: request_headers,
                             body: payload)
  end
end
