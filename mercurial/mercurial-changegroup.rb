#!/usr/bin/env ruby

require 'net/https'
require 'json'
require 'uri'
require 'securerandom'
require 'pathname'
require 'date'

def get_hg_file_contents(ref, fileName)
	contents = `hg cat #{fileName} -r #{ref}`
	if $?.success?
		contents
	else
		nil
	end	
end

def parse_commits(lines, separator)
	commits = []
	commit = {
		:author => {}
	}
	num = 1
	message = []
	lines.each { |line|
		case
		when num == 1
			commit[:branch] = line		
		when num == 2
			commit[:id] = line
		when num == 3
			commit[:author][:name] = line
		when num == 4
			commit[:author][:email] = line
		when num == 5
			commit[:timestamp] = DateTime.parse(line)
		when num == 6
			commit[:tag] = line
		when num > 6 && line != separator
			message << line
		when line == separator
			commit[:message] = message.join('\n')
			commits << commit

			num = 0
			message = []
			commit = {
				:author => {}
			}
		end
		num += 1
	}
	commits
end

commit_id = ENV["HG_NODE"]
repo_url = ENV["HG_URL"]

# current directory is repository root
repo_path = Dir.pwd
repo_name = Pathname.new(repo_path).basename

#puts "Input data: #{start_commit_id} #{end_commit_id} #{ref}"
#puts "Repository path: #{repo_path}"

# get git config
webhook_url = ARGV[0]
#puts "Webhook URL: #{webhook_url}"

comments_end = SecureRandom.hex

result = `hg log -r #{commit_id} --template "{branch}\n{node}\n{author|user}\n{author|email}\n{date|date}\n{tags}\n{desc}\n#{comments_end}\n"`.split("\n")
commits = parse_commits(result, comments_end)

#commits.each { |commit| puts "commit: #{commit[:id]}" }

# get blob contents
appveyor_yml = get_hg_file_contents(commit_id, "appveyor.yml")

payload = {
	:commit => commits.first,
	:repository => {
		:name => repo_name,
		:url => repo_url
	},
	:config => appveyor_yml
}

# send webhook
uri = URI(webhook_url)
req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
# ruby 2.0: req = Net::HTTP::Post.new uri
#req.basic_auth 'username', 'password'
req.body = payload.to_json

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == "https") do |http|
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	http.request req
end

if response.code != "200" and response.code != "204"
	raise "Error sending webhook: #{response.code}"
end
