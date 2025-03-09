require "json"
require "pp"
require "uri"
require "date"

USER     = ARGV[0]
APP_PASSWORD = ARGV[1]

if USER.nil? || APP_PASSWORD.nil?
  raise "[USAGE] ruby backup.rb USER_NAME APP_PASSWORD"
end

OUTPUT_DIR = "output/#{Date.today}"

def get_all_repository_names
  puts "START get_all_repository_names"

  all_names = []
  page_id = 1

  loop do
    puts "==== page: #{page_id} ===="
    repository_names, page_id = get_repository_names(page_id)
    all_names += repository_names

    break if page_id.nil?

    sleep 1
  end

  all_names.sort
end

def get_repository_names(page_id)
  command   = "curl -s --user #{USER}:#{APP_PASSWORD} https://api.bitbucket.org/2.0/repositories/#{USER}?page=#{page_id}"
  response  = JSON.parse(`#{command}`)
  repository_names = response["values"].map{|value| value["name"] }
  next_page_id = parse_page_id(response["next"])

  [repository_names, next_page_id]
end

def parse_page_id(next_page_uri)
  return if next_page_uri.nil?

  uri = URI::parse(next_page_uri)
  return if uri.query.nil?

  queries = URI::decode_www_form(uri.query)
  Hash[queries]["page"]&.to_i
end

def archive_git_repository(repository_name)
  repository = "git@bitbucket.org:#{USER}/#{repository_name}.git"
  command = "git archive HEAD --remote=#{repository} --output=#{OUTPUT_DIR}/#{repository_name}.zip"
  puts command
  system(command)
end

def archive_all_git_repositories(repository_names)
  puts "START archive_all_git_repositories"

  repository_names.each do |repository_name|
    archive_git_repository(repository_name)
    sleep 1
  end
end

def write_log(string)
  file_path = "#{OUTPUT_DIR}/log.txt"
  File.write(file_path, string)
end

def create_output_dir
  return if Dir.exist?(OUTPUT_DIR)
  Dir.mkdir(OUTPUT_DIR)
end

def main
  puts "START #{USER}"

  create_output_dir

  repository_names = get_all_repository_names
  write_log(repository_names.join("\n"))

  archive_all_git_repositories(repository_names)

  puts "FINISH"
end

main

