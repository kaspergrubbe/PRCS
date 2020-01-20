RSpec.describe PRCS do
  it "has a version number" do
    expect(PRCS::VERSION).not_to be nil
  end

  it "should inherit and mask some methods from ChildProcess" do
    prcs = PRCS::Runner.new(["false"]).run!
    sleep(0.2)

    expect(prcs.alive?).to be false
    expect(prcs.exited?).to be true
    expect(prcs.exit_code).to eq 1
  end

  it "should be able to consume the stdout/stderr" do
    prcs = PRCS::Runner.new(["bash", "spec/scripts/test.sh"]).run!
    sleep(0.2)

    # Sanity
    expect(prcs.alive?).to be true
    expect(prcs.exit_code).to be nil
    expect{prcs.stdout}.to raise_error(RuntimeError, "Process still alive, use queue-method instead")
    expect{prcs.stderr}.to raise_error(RuntimeError, "Process still alive, use queue-method instead")

    # Collect logs
    sleep(5)

    stdout = prcs.stdout_queue
    stderr = prcs.stderr_queue
    expect(stdout.split("\n").count).to be > 1
    expect(stdout.split("\n").count).to be stderr.split("\n").count

    prcs.kill!(1)

    # Make sure that queued logs are stored
    stdout = stdout.concat(prcs.stdout_queue)
    stderr = stderr.concat(prcs.stderr_queue)

    expect(prcs.stdout).to eq stdout
    expect(prcs.stderr).to eq stderr
  end
end
