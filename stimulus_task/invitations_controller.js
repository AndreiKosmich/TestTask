import { Controller } from 'stimulus'
import { notification, serverErrorNotification } from '../components/notification'

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
        method: 'POST',
        'Content-Type': 'application/json'
      }
    }).then(res => {
      this.invitationLink.setAttribute('disabled', true)
      this.invitationLink.classList.add('disabled')
      this.invitationLink.textContent = this.disabledTextValue
      this.changeNextPageButton(document.getElementsByClassName(this.nextPageButtonValue))
      notification(res.message, 'notice')
    }).catch((error) => serverErrorNotification(error))
  }

  changeNextPageButton(elements) {
    if (!elements) return

    elements.forEach((element) => {
      element.textContent = this.nextPageAfterTextValue
      element.classList.replace('btn-primary', 'btn-secondary')
    })
  }
}
