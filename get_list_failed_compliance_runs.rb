require 'httparty'
require 'json'

# Authentication credentials for the Chef Automate server
automate_url = 'https://automate.example.com'
username = 'myusername'
password = 'mypassword'

# Create a connection to the Chef Automate server
connection = HTTParty.post("#{automate_url}/api/v0/authenticate/userpass",
                           body: { userid: username, password: password }.to_json,
                           headers: { 'Content-Type' => 'application/json' })
token = connection['token']

# Set the search parameters for the compliance scanner jobs
search_params = {
  query: 'status:failed',
  end_time: Time.now.to_i * 1000 # set the end time to now
}

# Search for compliance scanner jobs that failed
response = HTTParty.post("#{automate_url}/api/v0/compliance/scanner/jobs/search",
                         body: search_params.to_json,
                         headers: { 'Content-Type' => 'application/json', 'api-token' => token })

# Parse the JSON object to extract the list of nodes where compliance scanning did not run
failed_jobs = JSON.parse(response.body)['jobs']

# Get the list of nodes where compliance scanning did not run
failed_nodes = failed_jobs.map { |job| job['node_name'] }.uniq

# Return a list of the names of the nodes where compliance scanning did not run
puts "The following nodes did not have compliance scanning run:"
puts failed_nodes.join("\n")
