function clickTab(id){
    document.getElementById(id).click();
    return false;
}


window.addEventListener("load", (event) => {
if (window.location.hash == "#events") {
    clickTab('events')
}
if (window.location.hash == "#hist") {
    clickTab('hist')
}
if (window.location.hash == "#links") {
    clickTab('links')
}
});


window.addEventListener("hashchange", (event) => {
    if (window.location.hash == "#events") {
        clickTab('events')
    }
    if (window.location.hash == "#hist") {
        clickTab('hist')
    }
    if (window.location.hash == "#links") {
        clickTab('links')
    }
    });