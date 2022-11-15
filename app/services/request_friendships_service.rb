class RequestFriendshipsService < ApplicationService

  def initialize(from:, to:)
    @from = from
    @to = to
  end

  attr_reader :from, :to

  def call
    from.add_friend(to)
    Notification.create(
      user_id: to.id,
      payload: Notification::PAYLOAD[:friend_request].call(from)
    )
  end

  private

end
