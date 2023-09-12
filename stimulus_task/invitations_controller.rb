class InvitationsController < ApplicationController
  before_action :authenticate_user!, only: :index

  def create
    invitation = Invitation.new(job_id: params[:job_id], user_id: current_user.id)

    if invitation.save
      redirect_back_or_to root_url, notice: 'Thank you for your invitation!'
    else
      render invitations_path, alert: 'Something went wrong. Please try again.'
    end
  end

  def index
    last_invitation = current_user.invitations.last

    render locals: { tradesman: current_user, invitation: last_invitation, job: last_invitation.job }
  end
end