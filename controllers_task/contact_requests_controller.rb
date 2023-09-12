class ContactRequestsController < ApplicationController
  before_action :tradesman_login, only: [:create]

  include Concerns::V5::ContactRequestParticipateable

  def create
    (redirect_back(fallback_location: users_path) && return) unless job

    set_attributes

    if @contact_request.save
      send_contact_request
      redirect_back(
        fallback_location: job_path(job),
        flash: { notice: t(:Contact_request_sent_to_employer) }
      )
    else
      redirect_to(
        job_path(job),
        flash: { error: @contact_request.errors.full_messages.join(', <br> ').html_safe }
      )
    end
  end

  private

  def tradesman_login
    'auth logic'
  end

  def set_attributes
    @job_creator = job.creator
    @tradesman = current_user
    @contact_request_purpose_key = params[:purpose]
    @contact_request = ContactRequest.new(user_id: @tradesman.id, job_id: @job.id, purpose: @contact_request_purpose_key)
  end

  def send_contact_request
    # TODO: Implement using sidekiq for asynchronous notification
    EmailNotification.delay.contact_request_employer(
      recipient_address: @job_creator.email,
      tradesman: @tradesman,
      job: @job,
      job_url: permalink_job_comparisons_url(@job.token, contact_request: true),
      contact_request_id: @contact_request.id,
      job_creator: @job_creator,
      subject: I18n.t(:Contact_request_for, job_title: @job.title),
      purpose: ContactRequest::PURPOSE[@contact_request.purpose.to_sym]
    )
  end
end

module Concerns::V5::ContactRequestParticipateable
  extend ActiveSupport::Concern

  included do
    before_action :requires_premium_membership, only: :create
  end

  protected

  def requires_premium_membership
    return unless v5_current_pricing?

    @action = Participation::ACTIONS[:contact_request]
    @category = @job.categories.first

    if participate_as_basic_member?
      redirect_to(
        new_user_subscription_path(current_user),
        flash: { error: 'Participation only possible for premium members' } # TODO: Use I18n
      )
    end
  end

  def v5_current_pricing?
    current_user.pricings.current.v5?
  end

  def job
    @job ||= Job.find(params[:job_id])
  end

  def participate_as_basic_member?
    current_subscription = current_user.subscriptions.last # TODO: Use model scope

    current_subscription.blank? || (current_subscription && !current_subscription.is_valid?)
  end
end
