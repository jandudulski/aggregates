require "aggregate_root"

module ProjectManagement
  class Issue
    include AggregateRoot

    InvalidTransition = Class.new(StandardError)

    def initialize(id)
      @id = id
    end

    def create
      invalid_transition unless can_create?
      apply(IssueOpened.new(data: { issue_id: @id }))
    end

    def resolve
      invalid_transition unless can_resolve?
      apply(IssueResolved.new(data: { issue_id: @id }))
    end

    def close
      invalid_transition unless can_close?
      apply(IssueClosed.new(data: { issue_id: @id }))
    end

    def reopen
      invalid_transition unless can_reopen?
      apply(IssueReopened.new(data: { issue_id: @id }))
    end

    def start
      invalid_transition unless can_start?
      apply(IssueProgressStarted.new(data: { issue_id: @id }))
    end

    def stop
      invalid_transition unless can_stop?
      apply(IssueProgressStopped.new(data: { issue_id: @id }))
    end

    private

    def invalid_transition
      raise InvalidTransition
    end

    def open?
      @status == :open
    end

    def closed?
      @status == :closed
    end

    def in_progress?
      @status == :in_progress
    end

    def reopened?
      @status == :reopened
    end

    def resolved?
      @status == :resolved
    end

    def can_reopen?
      closed? || resolved?
    end

    def can_start?
      open? || reopened?
    end

    def can_stop?
      in_progress?
    end

    def can_close?
      open? || in_progress? || reopened? || resolved?
    end

    def can_resolve?
      open? || reopened? || in_progress?
    end

    def can_create?
      @status.nil?
    end

    on IssueOpened do |ev|
      @status = :open
    end

    on IssueResolved do |ev|
      @status = :resolved
    end

    on IssueClosed do |ev|
      @status = :closed
    end

    on IssueReopened do |ev|
      @status = :reopened
    end

    on IssueProgressStarted do |ev|
      @status = :in_progress
    end

    on IssueProgressStopped do |ev|
      @status = :open
    end
  end
end
