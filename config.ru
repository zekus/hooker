require './lib/gitsync'

class Hooker
  def handle_request
    payload = @req.POST["payload"]

    return @res.write "go away fool" if payload.nil?

    # sync the thing
    @basedir = ENV['PUPPET_ENVIRONMENTS_ROOT']
    @local_repo = ENV['PUPPET_LOCAL_REPO']
    @source = ENV['PUPPET_GIT_REPO']

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
