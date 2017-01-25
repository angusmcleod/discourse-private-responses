# name: discourse-private-responses
# about: Allows the creation of topics where each poster only sees their post
# version: 0.1
# authors: Angus McLeod

after_initialize do

  module PrivateResponseExtension
    def filter_posts_by_ids(post_ids)
      @posts = super(post_ids)
      private_responses_enabled = CategoryCustomField.where(category_id: @topic.category_id, name: "private_responses_enabled").pluck('value')
      if private_responses_enabled && @topic.user_id != @user.id
        @posts = @posts.where("posts.user_id = ? OR post_number = ?", @user.id, 1)
      end
      @posts
    end
  end

  require 'topic_view'
  class ::TopicView
    prepend PrivateResponseExtension
  end

  add_to_serializer(:basic_category, :private_responses_enabled) {object.custom_fields["private_responses_enabled"]}
end
