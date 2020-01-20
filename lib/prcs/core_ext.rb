class IO
  # Inspired by https://github.com/Homebrew/brew/blob/6b2dbbc96f7d8aa12f9b8c9c60107c9cc58befc4/Library/Homebrew/extend/io.rb
  def readline_nonblock
    buffer = ""
    buffer << read_nonblock(1) while buffer[-1] != "\n"

    buffer
  rescue IO::WaitReadable => blocking
    raise blocking if buffer.empty?

    buffer
  end
end
