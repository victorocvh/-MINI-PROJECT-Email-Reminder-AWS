
const STATIC_ENDPOINT = 'petcuddleotron';
var CHANGE_ENDPOINT = 'https://wnacr2ewfb.execute-api.us-east-1.amazonaws.com/prod';
var API_ENDPOINT = `${CHANGE_ENDPOINT}/${STATIC_ENDPOINT}`;
// if correct it should be similar to https://somethingsomething.execute-api.us-east-1.amazonaws.com/prod/petcuddleotron

var errorDiv = document.getElementById('error-message')
var successDiv = document.getElementById('success-message')
var resultsDiv = document.getElementById('results-message')

// function output returns input button contents
function waitSecondsValue() { return document.getElementById('waitSeconds').value }
function messageValue() { return document.getElementById('message').value }
function emailValue() { return document.getElementById('email').value }

function clearNotifications() {
    errorDiv.textContent = '';
    resultsDiv.textContent = '';
    successDiv.textContent = '';
}

// When buttons are clicked, this is run passing values to API Gateway call
document.getElementById('emailButton').addEventListener('click', function(e) { sendData(e, 'email'); });

function sendData (e, pref) {
    e.preventDefault()
    clearNotifications()
    fetch(API_ENDPOINT, {
        headers:{
            "Content-type": "application/json"
        },
        method: 'POST',
        body: JSON.stringify({
            waitSeconds: waitSecondsValue(),
            message: messageValue(),
            email: emailValue()
        }),
        mode: 'no-cors'
    })
    .then((resp) => resp.json())
    .then(function(data) {
        console.log(data)
        successDiv.textContent = 'Submitted. But check the result below!';
        resultsDiv.textContent = JSON.stringify(data);
    })
    .catch(function(err) {
        errorDiv.textContent = 'Oops! Error Error:\n' + err.toString();
        console.log(err)
    });
};
