# Stimulus Code Task


Here we want to use an Stimulus controller to update the page on the fly after an invitation is created.

We should:
- Disable the invitation button and update its text
- Update the nextPage button
- Show a notification

Can you please take a look at the code and check if you see anything wrong, if you would change anything, or if you would choose a different approach?

```ruby
# invitations_controller.rb

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
    render locals: { tradesman: current_user, invitation: current_user.invitations.last, job: current_user.invitations.last.job }
  end
end
```

```javascript
// app/javascript/controllers/invitations_controller.js

import {Controller} from 'stimulus'
import {notification, serverErrorNotification} from '../components/notification'

export default class extends Controller {
    static targets = ['invitationLink']

    static values = {
        createUrl: String,
        disabledText: String,
        tradesmanId: Number,
        jobId: Number,
        nextPageButton: String,
        nextPageAfterText: String
    }

    createInvitation() {
        fetch(this.createUrlValue, {
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(res => {
            this.invitationLink.setAttribute('disabled', true)
            this.invitationLink.classList.add('disabled')
            this.invitationLink.textContent = this.disabledTextValue
            this.changeNextPageButton(document.getElementsByClassName(this.nextPageButtonValue))
            notification(res.message, 'notice')
        }).catch(() => serverErrorNotification())
    }

    changeNextPageButton(elements) {
        if (!elements) return

        Array.from(elements).forEach(element => {
            element.textContent = this.nextPageAfterTextValue
            element.classList.replace('btn-primary', 'btn-secondary')
        })
    }
}
```

```html
<!-- app/views/invitations/index.html.erb -->

<div class="col-sm-9 mb-3 mb-sm-0">
<%= link_to t(:continue), job_proposals_path(service.job.id, params.permit(:new_job_posted, :pageflow)), class: "btn btn-primary" %>
  <div class="d-sm-inline-flex">
<h6 class="mb-0 font-weight-bold"><%= tradesman.company_info.company_name %></h6>
  </div>
</div>
<div class="col-sm-3 text-sm-right align-self-center">
<%= link_to "#",
              class: "btn btn-primary view-profile-btn w-100 btn-xs-block #{'disabled' if invitation}",
              disabled: invitation.present?,
              data: {
                controller: 'invitations',
                action: 'invitations#createInvitation',
                invitations_target: 'invitationLink',
                invitations_create_url_value: invitations_path(invitation: {tradesman_id: tradesman.id, job_id: job.id }),
                invitations_disabled_text_value: t('invitations.quote_requested'),
                invitations_next_page_after_text_value: t(:continue)
              } do %>
    <%= invitation ? t('invitations.quote_requested') : t('Quote_requests') %>
<% end %>
<%= link_to business_profile_path(company_name_url: tradesman.company_name_url, pageflow: 'suggested_tradespeople_list', job_id: job.id),
              class: "mt-3 w-100 btn btn-secondary view-profile-btn btn-xs-block",
              target: '_blank' do %>
    <%= t('view_profile') %>
<% end %>
<%= link_to t(:continue), job_proposals_path(service.job.id, params.permit(:new_job_posted, :pageflow)), class: "btn btn-primary" %>
</div>
```