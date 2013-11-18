# StashableParams

[![Build
Status](https://travis-ci.org/linstula/stashable_params.png?branch=master)](https://travis-ci.org/linstula/stashable_params)

Easily store the current params hash  and access them when you need them. 

Call `stash_params` in your controller to store the current params. Call
`unstash_params` to retrieve the stashed params and access them from the params hash.

## Installation

Add this line to your application's Gemfile:

    gem 'stashable_params'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stashable_params

## Usage

`stashed_params` provides helper methods that allow you to stash and
unstash parameters for later use. To have access to these methods in
your controllers, include StashableParams in `app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery
  include StashableParams
end
```

### Stashing and Unstashing Params

Any controller that inherits from ApplicaitonController now has access
to the `stash_params` and `unstash_params` helper methods. 

Call `stash_params` to store the current params hash. Call
`unstash_params` to retrieve the stashed params. After unstashing the
params, they will be available as part of the current params hash.

### Params Filter

`stashable_params` provides a default filter for filtering out
potentially sensitive parameter keys such as `:password` and
`:password_confirmation`. These keys will not be stored when
`stash_params` is called. The `:action` and `:controller` keys are also
part of the default params filter.

### Customizing the Params Filter

If you do not wish to store specific parameter keys you can create a
custom params filter. To do this, define a `params_filter` method that
returns an array of keys you do not wish to store. NOTE: This will
overwrite the default params filter of:

`[:password, :password_confirmation, :action, :controller]`

It is recommended that you also include these keys in your custom filter.

```ruby 
class ApplicationController < ActionController:Base
  protect_from_forgery
  include StashableParams
  
  def params_filter
    [:my_sensitive_key, :password, :password_confirmation, :action, :controller]
  end
end
```

### Example Usage

Here's an example of stashing params so we can ask a user to confirm
their identity before creating a comment. 

Our application requires that a user must confirm their identity before 
a comment is created if they have not signed in within the last 24
hours. So, if a user has signed in recently we create the comment. If
not, we redirect them to the sign in page to confirm their identity and 
redirect them back to the `new_comment_path` so they can resubmit their
comment.

We'll stash the params before the user gets redirected to the sign in
page and unstash them when the user gets back to the `new_comment_path`
so we can repopulate the comment fields and save the user from having to
retype the fields.

```ruby
class CommentsController < ApplicationController

  #...

  def new
    unstash_params
    @comment = Comment.new(comment_params)
  end
  
  def create
    if user_not_signed_in_recently
      stash_params
      redirect_to sign_in_path  
    end 
    
    @comment = Comment.new(comment_params)

    # Code to save comment...
  end

  private

  def comment_params
    params.require(:comment).permit(:content) if params(:comment)
  end 

  #...

end
```

Now, when our user gets redirected back to the new comment page the
comment fields will be populated with the content the user previously
submitted.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
