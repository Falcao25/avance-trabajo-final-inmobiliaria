document.addEventListener("DOMContentLoaded", () => {
    const toggle = document.querySelector("[data-menu-toggle]");
    const menu = document.querySelector("[data-nav-menu]");

    if (!toggle || !menu) {
        return;
    }

    toggle.addEventListener("click", () => {
        const menuClass = toggle.hasAttribute("data-bootstrap-menu") ? "show" : "is-open";
        const isOpen = menu.classList.toggle(menuClass);
        toggle.setAttribute("aria-expanded", String(isOpen));
    });
});
