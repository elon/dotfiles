# see rake -T

require 'rake'
require 'fileutils'

EXCLUDES = %w( . .. .git .gitignore .vim LICENSE README.md Rakefile)
REJECT_FILTERS = [ /\.swp$/, /\.swo$/ ]

$noop = false
$verbose = true

VIM_REPOS = [
  %w(tpope vim-surround),
  %w(tpope vim-rails),
  %w(tpope vim-endwise),
  %w(tpope vim-markdown),
  %w(tpope vim-eunuch),
  %w(tpope vim-fugitive),
  %w(tpope vim-bundler),
  %w(mileszs ack.vim),
  %w(scrooloose nerdtree),
]

PATHOGEN_URL = 'https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim'
BUFEXPLORER_URL = 'http://www.vim.org/scripts/download_script.php?src_id=18766'
MUSTANG_URL = 'http://www.vim.org/scripts/download_script.php?src_id=11274'
SNIPMATE_URL = 'http://www.vim.org/scripts/download_script.php?src_id=11006'

module Dotfile

  def dotfiles &block
    files = Dir.glob('.*') - EXCLUDES
    files = filter_rejects files
    files.each { |file| yield file }
  end

  def binfiles &block
    files = Dir.glob('bin/**/*') - EXCLUDES
    files = filter_rejects files
    files.each { |file| yield file }
  end

  def filter_rejects files, filters=REJECT_FILTERS.dup
    if filters.length == 0
      files
    else
      filter = filters.shift
      files = files.reject {|f| f =~ filter }
      filter_rejects files, filters
    end
  end

  def home *file
    file == nil ? ENV['HOME'] : File.join(ENV['HOME'], *file)
  end

  def pwd *file
    file == nil ? Dir.pwd : File.join(Dir.pwd, *file)
  end

  def install src, dest
    return if File.symlink?(dest) && File.readlink(dest) == src
    if File.file?(dest) || File.directory?(dest)
      backup dest
    end
    link src, dest
  end

  def uninstall dest
    FileUtils.rm(dest, fileopts) if File.symlink?(dest)
    bak = bakname dest
    if File.file?(bak)
      FileUtils.mv bak, dest, fileopts
    end
  end

  def bakname file
    "#{file}.dotfile-"
  end

  def backup file
    bak = bakname file
    if File.file?(bak)
      raise IOError.new("redundant backup failed!: #{file}") 
    end
    FileUtils.mv file, bak, fileopts
  end

  def link src, dest
    FileUtils.ln_s src, dest, fileopts
  end

  def fileopts
    { :noop => $noop, :verbose => $verbose }
  end

  def clone user, repo
    exec_ext "git clone git://github.com/#{user}/#{repo}.git #{repo}"
  end

  def curl path, url
    exec_ext "curl -SLo #{path} #{url}"
    path
  end

  def exec_ext cmd
    unless $noop
      out = system(cmd)
      puts out if $verbose
    end
  end

  def export user, repo, parent_dir
    raise IOError.new('bad file') if repo.strip == '' || parent_dir.strip == ''
    dir = File.join(parent_dir, repo)
    FileUtils.rm_rf dir, fileopts
    clone user, repo
    FileUtils.rm_rf File.join(dir, '.git'), fileopts
  end

  def unzip file, dir
    puts `unzip -u #{file} -d #{dir}` unless $noop
    dir
  end

end

extend Dotfile

desc 'install dot files'
task :install do
  dotfiles { |f| install pwd(f), home(f) }
  mkdir_p home('bin'), fileopts unless File.directory?(home('bin'))
  binfiles { |f| install pwd(f), home(f) }
end

desc 'uninstall dot files'
task :uninstall do
  dotfiles { |f| uninstall home(f) }
  binfiles { |f| uninstall home(f) }
end

desc 'sets noop - chain this before another task'
task :dry do
  $noop = true
end

desc 'list dot files'
task :list do
  dotfiles { |file| puts file }
  binfiles { |file| puts file }
end

desc 'install vim plugins'
task :vim do
  dirs = []
  dirs << bundle = home('.vim', 'bundle')
  dirs << auto = home('.vim', 'autoload')
  dirs << colors = home('.vim', 'colors')
  dirs << bufdir = File.join(bundle, 'bufexplorer')
  dirs << snipdir = File.join(bundle, 'snipmate')
  dirs.each { |d| FileUtils.mkdir_p d, fileopts }

  curl File.join(auto, 'pathogen.vim'), PATHOGEN_URL
  curl File.join(colors, 'mustang.vim'), MUSTANG_URL

  bufzip = File.join(bundle, 'bufexplorer.zip')
  unzip curl(bufzip, BUFEXPLORER_URL), bufdir

  snipzip = File.join(bundle, 'snipMate.zip')
  unzip curl(snipzip, SNIPMATE_URL), snipdir

  Dir.chdir bundle
  VIM_REPOS.each { |repo| export(*repo, bundle) }
end
