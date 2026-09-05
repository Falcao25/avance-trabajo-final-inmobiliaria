document.addEventListener("DOMContentLoaded", () => {
    const form = document.querySelector("[data-login-form]");
    const toggle = document.querySelector("[data-toggle-password]");
    const password = document.querySelector("[data-login-password]");

    if (toggle && password) {
        toggle.addEventListener("click", () => {
            password.type = password.type === "password" ? "text" : "password";
            toggle.textContent = password.type === "password" ? "Mostrar" : "Ocultar";
        });
    }

    if (!form) {
        return;
    }

    form.addEventListener("submit", (event) => {
        const user = String(form.querySelector("[name='usuario']")?.value || "").trim();
        const pass = String(form.querySelector("[name='password']")?.value || "").trim();

        if (!user || !pass) {
            event.preventDefault();
            alert("Completa usuario y contraseña.");
        }
    });
});
