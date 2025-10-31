// Hamburger menu toggle
document.addEventListener('DOMContentLoaded', function() {
    var hamburger = document.getElementById('sidepanel_hamburger');
    if (hamburger) {
        hamburger.addEventListener('click', function(ev) {
            var sidepanels = document.getElementsByClassName('sidepanel');
            for (var i = 0; i < sidepanels.length; i++) {
                sidepanels[i].classList.toggle('opened');
            }
            ev.preventDefault();
        });
    }
});
