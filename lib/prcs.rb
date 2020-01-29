require "prcs/version"
require "prcs/core_ext"

require "childprocess"

module PRCS
  class Error < StandardError; end

  class Runner
    def initialize(command)
      @command = command
      @process = nil
      @stdout = nil
      @stderr = nil

      @external_queues = {}.tap do |it|
        it[:stdout] = Queue.new
        it[:stderr] = Queue.new
      end
      @logcollectors = {}
    end

    def run!(stdin = nil)
      stdout_pipe, stdout_wr = IO.pipe
      stderr_pipe, stderr_wr = IO.pipe

      ChildProcess.posix_spawn = true
      @process = ChildProcess.build(*@command)
      @process.duplex = true if stdin
      @process.io.stdout = stdout_wr
      @process.io.stderr = stderr_wr

      @process.start

      stdout_wr.close
      stderr_wr.close

      if stdin
        @process.io.stdin.write(stdin)
        @process.io.stdin.close
      end

      @logcollectors[:stdout] = Thread.new(stdout_pipe) do |pipe|
        Thread.current[:running] = true
        Thread.current[:log] = ""

        while Thread.current[:running]
          begin
            output = pipe.readline_nonblock
            @external_queues[:stdout] << output
            Thread.current[:log] << output
            sleep(0.1)
          rescue IO::EAGAINWaitReadable
          end
        end
      end

      @logcollectors[:stderr] = Thread.new(stderr_pipe) do |pipe|
        Thread.current[:running] = true
        Thread.current[:log] = ""

        while Thread.current[:running]
          begin
            output = pipe.readline_nonblock
            @external_queues[:stderr] << output
            Thread.current[:log] << output
            sleep(0.1)
          rescue IO::EAGAINWaitReadable
          end
        end
      end

      self
    end

    def run_and_wait!
      self.run!
      @process.wait

      self
    end

    def kill!(timeout = 15)
      @logcollectors.values.each do |collector_thread|
        collector_thread[:running] = false
      end

      begin
        @process.poll_for_exit(timeout)
      rescue ChildProcess::TimeoutError
        @process.stop
      end

      @logcollectors.values.each do |collector_thread|
        Thread.kill(collector_thread)
      end

      @stdout = @logcollectors[:stdout][:log]
      @stderr = @logcollectors[:stderr][:log]

      self
    end

    def stdout_queue
      "".tap { |it|
        begin
          while(true)
            it << @external_queues[:stdout].pop(true)
          end
        rescue ThreadError
        end
      }
    end

    def stderr_queue
      "".tap { |it|
        begin
          while(true)
            it << @external_queues[:stderr].pop(true)
          end
        rescue ThreadError
        end
      }
    end

    def stdin
      @process.io.stdin
    end

    def stdout
      if alive?
        raise "Process still alive, use queue-method instead"
      else
        @stdout
      end
    end

    def stderr
      if alive?
        raise "Process still alive, use queue-method instead"
      else
        @stderr
      end
    end

    def alive?
      @process.alive?
    end

    def exited?
      @process.exited?
    end

    def exit_code
      @process.exit_code
    end
  end
end
