module ProjectManagement
  class Handler
    def initialize(event_store)
      @event_store = event_store
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
      load_issue(id) do |issue|
        issue.open
        IssueOpened.new(data: { issue_id: id })
      end
    end

    def close(id)
      load_issue(id) do |issue|
        issue.close
        IssueClosed.new(data: { issue_id: id })
      end
    end

    def start(id)
      load_issue(id) do |issue|
        issue.start
        IssueProgressStarted.new(data: { issue_id: id })
      end
    end

    def stop(id)
      load_issue(id) do |issue|
        issue.stop
        IssueProgressStopped.new(data: { issue_id: id })
      end
    end

    def reopen(id)
      load_issue(id) do |issue|
        issue.reopen
        IssueReopened.new(data: { issue_id: id })
      end
    end

    def resolve(id)
      load_issue(id) do |issue|
        issue.resolve
        IssueResolved.new(data: { issue_id: id })
      end
    end

    private

    def stream_name(id)
      "Issue$#{id}"
    end

    def load_issue(id)
      issue = Issue.new
      @event_store
        .read
        .stream(stream_name(id))
        .each do |event|
          case event
          when IssueOpened
            issue = issue.open
          when IssueProgressStarted
            issue = issue.start
          when IssueProgressStopped
            issue = issue.stop
          when IssueResolved
            issue = issue.resolve
          when IssueReopened
            issue = issue.reopen
          when IssueClosed
            issue = issue.close
          end
        end
      events = yield issue
      @event_store.append(events, stream_name: stream_name(id))
    end
  end
end
