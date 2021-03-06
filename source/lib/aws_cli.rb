require_relative 'base_stacker'

class AwsCli < BaseStacker
  def cmd(cmd, debug)
    cmd = "AWS_ACCESS_KEY_ID=#{@creds.access_key_id} \
    AWS_SECRET_ACCESS_KEY=#{@creds.secret_access_key} \
    AWS_SESSION_TOKEN=#{@creds.session_token} \
    aws #{cmd}"
    puts cmd if debug
    puts `#{cmd}`
  end

  def console(options)
    session_json = {
    	sessionId: @creds.access_key_id,
    	sessionKey: @creds.secret_access_key,
    	sessionToken: @creds.session_token
  	}.to_json

    issuer_url = "Stacker"
    console_url = "https://console.aws.amazon.com/"
    signin_url = "https://signin.aws.amazon.com/federation"

    get_signin_token_url = signin_url + "?Action=getSigninToken" + "&SessionType=json&Session=" + CGI.escape(session_json)
    returned_content = Net::HTTP.get(URI.parse(get_signin_token_url))
    signin_token = JSON.parse(returned_content)['SigninToken']
    signin_token_param = "&SigninToken=" + CGI.escape(signin_token)
    issuer_param = "&Issuer=" + CGI.escape(issuer_url)
    destination_param = "&Destination=" + CGI.escape(console_url)
    login_url = signin_url + "?Action=login" + signin_token_param + issuer_param + destination_param
    puts login_url if options[:debug]

    `open \"#{login_url}\"`
  end
end
