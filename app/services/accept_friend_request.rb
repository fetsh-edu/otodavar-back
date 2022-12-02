class AcceptFriendRequest
  include Interactor

  def call
    context.request.confirmed = true
    unless context.request.save
      context.fail!(errors: (context.errors || []).concat(context.request.errors.full_messages))
    end
  end
end
