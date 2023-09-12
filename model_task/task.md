# User Model Review


Here you can find some rather mysterious method defined on User model (again - don't worry this code doesn't live in the wild, at least anymore)

You don't know the internals or how those methods are being used but can you noticed some more or less obvious issues with this code?

Let's prepare a secret gist with alternative approach and your thoughts about it!
```ruby
class User < ApplicationRecord
  def is_tradesman?
    @is_tradesman ||= role_id == Role.find_by(name: 'Tradesman')&.id
  end

  def is_employer?
    @is_employer ||= role_id == Role.find_by(name: 'Employer')&.id
  end

  def is_collaborator?
    @is_collaborator ||= role_id == Role.find_by(name: 'Collaborator')&.id
  end

  def can_access_forum?(args)
    @job = args[:job]
    @user = self
    return true if @user == @job.creator || @user.is_tradesman?
    false
  end

  def creator?(job)
    return true if job.creator == self
    return false
  end

  def already_quoted(job)
    quote = Quote.where(user_id: self.id, job_id: job.id)

    return true if quote.size >= 1
    return false
  end

  def previous_quote_id(job)
    quote = Quote.where(user_id: self.id, job_id: job.id).first
    if quote.nil?
      return 0
    else
      return quote.id
    end
  end

  def previous_quote(job)
    quote = Quote.where(user_id: self.id, job_id: job.id).first
  end
end
```