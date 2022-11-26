class CreateFriendRequest
  include Interactor

  def call
    request = context.from.add_friend(context.to)
    if request.persisted?
      context.request = request
    else

      context.fail!(errors: (context.errors || []).concat(request.errors.full_messages))
    end
  end
end
