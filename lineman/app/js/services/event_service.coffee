angular.module('loomioApp').factory 'EventService', ($http, RecordStoreService, EventModel) ->
  new class EventService
    fetch: (params, success, failure) ->
      $http.get("/api/v1/events?discussion_id=#{params.discussion_id}&page=#{params.page}").then (response) =>
        console.log response
        RecordStoreService.importRecords(response.data)

        # return discussions in the order they arrived
        ordered_ids = _.map response.data.events, (event) -> event.id
        events = RecordStoreService.get('events', ordered_ids)
        success(events)
      , (response) ->
        failure(response.data.error)

    subscribeTo: (eventSubscription) ->
      PrivatePub.sign(eventSubscription)
      PrivatePub.subscribe "/events", (data, channel) =>
        @consume(data) if data.event?

    consume: (data) ->
      if data.event?
        event = new EventModel(data.event)
        RecordStoreService.put(event)
      RecordStoreService.importRecords(data)
