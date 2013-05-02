require 'rubygems'
require 'minitest/autorun'
require './lib/gitsync'

class GitSyncTest < MiniTest::Unit::TestCase

  def setup
    basedir = "/tmp/etc/puppet/environments"
    local_repo = "/tmp/var/pph-puppet/repo"
    source = ""

    [basedir, local_repo].each { |f| FileUtils.mkdir_p(f) }

    @gs = GitSync.new basedir, local_repo, source
  end

  def teardown
    [@gs.basedir, @gs.local_repo].each { |f| FileUtils.rm_rf(f) }
  end

  def test_open_empty_repo

    @gs.repo = nil
    git_obj = MiniTest::Mock.new
    git_obj.expect :clone, true, [{:timeout => false, :branch => 'master'}, @gs.source, @gs.local_repo]
    grit_obj = MiniTest::Mock.new

    File.stub :exists?, false do
      Grit::Git.stub :new, git_obj do
        Grit::Repo.stub :new, grit_obj do
          @gs.git_open_or_init
        end
      end
    end

    assert grit_obj.verify
    assert git_obj.verify
  end

  def test_open_existing_repo

    @gs.repo = nil
    grit_obj = MiniTest::Mock.new

    File.stub :exists?, true do
      Grit::Repo.stub :new, grit_obj do
        @gs.git_open_or_init
      end
    end

    assert grit_obj.verify
  end

  def test_sync
    # mock the Grit::Remote obj
    remote_obj = MiniTest::Mock.new
    remote_obj.expect :name, 'origin/mock_remote'
    remote_obj.expect :name, 'origin/mock_remote'
    remote_obj2 = MiniTest::Mock.new
    remote_obj2.expect :name, 'origin/HEAD'
    remote_obj2.expect :name, 'origin/HEAD'

    # mock the Grit::Git obj
    git_obj = MiniTest::Mock.new
    def git_obj.gs=(var) @gs=var; end #provide the context to the mock obj
    def git_obj.git_dir; @gs.local_repo+'/.git'; end
    def git_obj.work_tree; @gs.local_repo; end

    git_obj.gs = @gs

    git_obj.expect :fetch, true, [{:all => true, :prune => true}]
    git_obj.expect :sh, true, ["#{Grit::Git.git_binary} --git-dir=#{@gs.local_repo}/.git --work-tree=#{@gs.local_repo} reset --hard HEAD"]
    git_obj.expect :sh, true, ["#{Grit::Git.git_binary} --git-dir=#{@gs.local_repo}/.git --work-tree=#{@gs.local_repo} checkout origin/mock_remote"]

    # mock the Grit::Repo obj
    grit_obj = MiniTest::Mock.new
    grit_obj.expect :remotes, [remote_obj2, remote_obj]
    def grit_obj.git
      git_obj
    end

    @gs.repo = grit_obj

    @gs.repo.stub :git, git_obj do
      FileUtils.stub :cp_r, true do
        FileUtils.stub :rm_rf, true do
          @gs.stub :env_cleanup, true do
            @gs.sync
          end
        end
      end
    end

    assert remote_obj.verify
    assert remote_obj2.verify
    assert grit_obj.verify
    assert git_obj.verify
  end

  def test_env_cleanup
    # mock the Grit::Remote obj
    remote_obj = MiniTest::Mock.new
    remote_obj.expect :name, 'origin/mock_remote'
    remote_obj.expect :name, 'origin/mock_remote'
    remote_obj.expect :name, 'origin/mock_remote'

    remote_obj2 = MiniTest::Mock.new
    remote_obj2.expect :name, 'origin/HEAD'
    remote_obj2.expect :name, 'origin/HEAD'
    remote_obj2.expect :name, 'origin/HEAD'

    # mock the Grit::Repo obj
    grit_obj = MiniTest::Mock.new
    grit_obj.expect :remotes, [remote_obj2, remote_obj]

    # create a test directory
    FileUtils.mkdir("#{@gs.basedir}/testdir")
    FileUtils.mkdir("#{@gs.basedir}/mock_remote")

    @gs.stub :repo, grit_obj do
      @gs.env_cleanup
    end

    refute File.exists?("#{@gs.basedir}/testdir"), Dir.glob("#{@gs.basedir}/*")
    assert File.directory? "#{@gs.basedir}/mock_remote"

    assert remote_obj.verify
    assert remote_obj2.verify
    assert grit_obj.verify
  end
end
