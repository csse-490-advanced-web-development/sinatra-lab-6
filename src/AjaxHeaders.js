export function ajaxHeaders() {
  let csrfToken = document.cookie.split('=')[1];
  console.log("CSRF is ", csrfToken)
  return {
    'Content-Type': 'application/json',
    'X-CSRFToken':  csrfToken,
    'HTTP_X_CSRF_TOKEN': csrfToken,
    'HTTP_X_REQUESTED_WITH': 'XMLHttpRequest',
    "X-Requested-With": "XMLHttpRequest"
  }
}

export default ajaxHeaders;
