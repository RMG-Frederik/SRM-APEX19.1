// Global constants and variables
const oldShowErrors = apex.message.showErrors;

// Override the default javescript alert
function alert(message) {
    console.warn('Calling a simple alert function not allowed in SRM. Please use apex.message.alert');
    apex.message.alert(message);
}
// Override the default confirm alert
function confirm(message, callback) {
    console.warn('Calling a simple confirm function not allowed in SRM. Please use apex.message.confirm');
    apex.message.confirm(message, callback);
}

// change the class on all errors from warning to danger
apex.message.showErrors = function() {
    oldShowErrors.apply(apex.message, arguments)
    $("#APEX_ERROR_MESSAGE .t-Alert").removeClass("t-Alert--warning").addClass("t-Alert--danger");
}