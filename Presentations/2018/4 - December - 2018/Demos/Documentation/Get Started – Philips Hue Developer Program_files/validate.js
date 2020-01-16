function newsletter_check_field(field, message) {
    if (!field) return true;
    if (field.type == "checkbox" && !field.checked) {
        alert(message);
        return false;
    }
        
    if (field.required !== undefined && field.required !== false && field.value == "") {
        alert(message);
        return false;
    }
    return true;
}

function newsletter_check(f) {
    var re = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-]{1,})+\.)+([a-zA-Z0-9]{2,})+$/;
    if (!re.test(f.elements["ne"].value)) {
        alert(newsletter.messages.email_error);
        return false;
    }
    if (!newsletter_check_field(f.elements["nn"], newsletter.messages.name_error)) return false;
    if (!newsletter_check_field(f.elements["ns"], newsletter.messages.surname_error)) return false;
    
    for (var i=1; i<newsletter.profile_max; i++) {
        if (!newsletter_check_field(f.elements["np" + i], newsletter.messages.profile_error)) return false;
    }
    
    if (!newsletter_check_field(f.elements["ny"], newsletter.messages.privacy_error)) return false;
    
    return true;   
}