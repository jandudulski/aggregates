module ProjectManagement
  class Handler
    def initialize(event_store)
      @repository = AggregateRepository.new(event_store)
    end

    def call(cmd)
      case cmd
      when CreateIssue
        create(cmd.id)
      when ResolveIssue
        resolve(cmd.id)
      when CloseIssue
        close(cmd.id)
      when ReopenIssue
        reopen(cmd.id)
      when StartIssueProgress
        start(cmd.id)
      when StopIssueProgress
        stop(cmd.id)
      end
    rescue Issue::InvalidTransition
      raise Error
    end

    def create(id)
      with_issue(id) { |issue| issue.create(id) }
    end

    def resolve(id)
      with_issue(id) { |issue| issue.resolve }
    end

    def close(id)
      with_issue(id) { |issue| issue.close }
    end

    def reopen(id)
      with_issue(id) { |issue| issue.reopen }
    end

    def start(id)
      with_issue(id) { |issue| issue.start }
    end

    def stop(id)
      with_issue(id) { |issue| issue.stop }
    end

    private

    def stream_name(id) = "Issue$#{id}"

    def with_issue(id)
      @repository.with_state(IssueState.new, stream_name(id)) do |state, store|
        yield Issue.new(state).link(store)
      end
    end
  end
end
