import React from 'react';
import { useQuery } from "react-query";
import { ajaxHeaders } from './AjaxHeaders';

async function getCurrentUser() {
    const response = await fetch(
        `/sessions/current_user`,
        { headers: ajaxHeaders() }
        );
    return response.json();
}


async function signOut(){
    fetch(
      `/session`,
      {
        headers: ajaxHeaders(),
        method: 'DELETE'
      }
    ).then(() => {
      debugger
      window.location.href = '/';
    }).catch((error) => {
      debugger
    });
}

function LoggedInHeader() {
    const { isLoading, isError, data } = useQuery("current_user", getCurrentUser);

    if (isLoading)
      return (
        <div className="container">
            <strong>Together, we can TODO it!</strong>
            <small>
                You are logged in as ...
            </small>
        </div>
      );

    if (isError)
      return (
        <div className="container">
            <strong>Together, we can TODO it!</strong>
            <p>
                There was an error.  Please refresh the page to try again.
            </p>
        </div>
      );

    return (
        <div className="container">
          <strong>Together, we can TODO it!</strong>
          <small>You are logged in as { data['email'] }</small>
          <form onSubmit={(e) => {e.preventDefault(); signOut()}}>
            <input type="submit" value="Sign Out" />
          </form>
        </div>
    );
}

export default LoggedInHeader;
