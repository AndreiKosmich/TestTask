class User < ApplicationRecord
  rolify # Add role methods by metaprogramming such as is_tradesman?, is_employer?, is_collaborator?

  DEFAULT_QUOTE_ID = 0

  def can_access_forum?(job)
    self == job.creator || is_tradesman?
  end

  def creator?(job)
    self == job.creator
  end

  def already_quoted?(job)
    Quote.exists?(user_id: id, job_id: job.id)
  end

  def previous_quote_id(job)
    quote = Quote.find_by(user_id: id, job_id: job.id)
    quote&.id || DEFAULT_QUOTE_ID
  end

  def previous_quote(job)
    Quote.find_by(user_id: id, job_id: job.id)
  end
end