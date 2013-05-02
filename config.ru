require './lib/gitsync'

class Hooker
  def handle_request
    payload = @req.POST["payload"]

    return @res.write "go away fool" if payload.nil?

    # sync the thing
    @basedir = "/etc/puppet/environments"
    @local_repo = "/var/pph-puppet/repo"
    @source = ENV['gitrepo']

    gitsync = GitSync.new @basedir, @local_repo, @source
    gitsync.git_open_or_init
    gitsync.sync

    @res.write "Ok"
  end

  def call(env)
    @req = Rack::Request.new(env)
    @res = Rack::Response.new
    handle_request
    @res.finish
  end
end

run Hooker.new
