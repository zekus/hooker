require 'rubygems'
require 'grit'

class GitSync
  attr_accessor :basedir, :local_repo, :source, :repo

  # injected for testing
  attr_writer :branch_remotes

  def initialize basedir, local_repo, source
    self.basedir = basedir
    self.local_repo = local_repo
    self.source = source
    self.repo = nil
  end

  # clone a new repo or open an existing one
  def git_open_or_init
    unless File.exists? "#{local_repo}/.git"
      gitrepo = Grit::Git.new(local_repo)
      gitrepo.clone({:timeout => false, :branch => 'master'}, source, local_repo)
    end
    self.repo = Grit::Repo.new local_repo
  end

  def sync
    git = repo.git
    git.fetch({:all => true, :prune => true})

    branch_remotes.each do |branch|
      branch_name = branch.name
      simple_branch_name = branch_name.split('/').last

      git.sh("#{Grit::Git.git_binary} --git-dir=#{git.git_dir} --work-tree=#{git.work_tree} reset --hard HEAD")
      git.sh("#{Grit::Git.git_binary} --git-dir=#{git.git_dir} --work-tree=#{git.work_tree} checkout #{branch_name}")

      FileUtils.rm_rf("#{basedir}/#{simple_branch_name}")
      FileUtils.cp_r local_repo, "#{basedir}/#{simple_branch_name}", :remove_destination => true
    end

    env_cleanup
  end

  # cleanup environments removed from the repo
  def env_cleanup
    branches = branch_remotes

    Dir.glob("#{basedir}/*").each do |file|
      FileUtils.rm_rf("#{file}") unless branches.any? { |b| b.name.split('/').last == file.split('/').last }
    end
  end

  private

  # return the remote branches excluding the head pointer
  def branch_remotes
    branches = repo.remotes.select do |branch|
      branch.name !~ /origin\/HEAD/
    end
  end

end
