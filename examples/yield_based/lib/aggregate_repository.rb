class AggregateRepository
  def initialize(event_store)
    @event_store = event_store
  end

  def with_aggregate(aggregate, stream)
    @event_store.read.stream(stream).each { |event| aggregate.apply(event) }

    store = ->(event) { @event_store.publish(event, stream_name: stream) }
    yield aggregate, store
  end
end
