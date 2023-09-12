# Obscure Controller Action with Related Module

Below is some obscure controller action with related module

Do you think it could be improved? What are your ideas for refactoring without seeing whole picture?

Can you suggest some better approach?

Feel free to assume what is going on and what potentially could be improved

Eg. you can write new controller/action/module and add some comments with your thought process

share a secret gist with your proposed solution

```ruby
class ContactRequestsController < ApplicationController
  before_action :needs_tradesman_login, only: [:create]
  include Concerns::V5::ContactRequestParticipateable

  def create
    @job = Job.find_by_id(params[:job_id])
    redirect_back(fallback_location: users_path) and return unless @job

    @job_creator = @job.creator
    @tradesman = current_user
    @contact_request_purpose_key = params[:purpose]
    @contact_request = ContactRequest.new(user_id: @tradesman.id,
                                          job_id: @job.id,
                                          purpose: @contact_request_purpose_key)

    if @contact_request.save
      EmailNotification.delay.contact_request_employer(recipient_address: @job_creator.email,
                                                       tradesman: @tradesman,
                                                       job: @job,
                                                       job_url: permalink_job_comparisons_url(@job.token, contact_request: true),
                                                       contact_request_id: @contact_request.id,
                                                       job_creator: @job_creator,
                                                       subject: I18n.t(:Contact_request_for, job_title: @job.title),
                                                       purpose: ContactRequest::PURPOSE[@contact_request.purpose.to_sym])
      redirect_back fallback_location: job_path(@job)
      flash[:notice] = t(:Contact_request_sent_to_employer)
    else
      redirect_to job_path(@job)
      flash[:error] = @contact_request.errors.full_messages.join(', <br> ').html_safe
    end
  end
end

module Concerns::V5::ContactRequestParticipateable
  extend ActiveSupport::Concern

  included do
    before_action(:only => :create) { |c| c.requires_premium_membership(job: Job.find_by_id(params[:job_id]), action: Participation::ACTIONS[:contact_request]) if current_user.pricings.current.v5? }
  end

  protected

  def requires_premium_membership(args)
    @job = args[:job]
    @action = args[:action]
    @user = current_user
    @category = @job.categories.first

    if participate_as_basic_member?(user: @user)
      flash[:error] = 'Participation only possible for premium members'
      redirect_to new_user_subscription_path(@user)
    end
  end

  def participate_as_basic_member?(args)
    user = args[:user]
    current_subscription = user.subscriptions.last

    current_subscription.blank? || (current_subscription && !current_subscription.is_valid?)
  end
end
```