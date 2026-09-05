document.addEventListener("DOMContentLoaded", () => {
    const form = document.querySelector("[data-filters-form]");
    const cards = Array.from(document.querySelectorAll("[data-property-card]"));

    if (!form || cards.length === 0) {
        return;
    }

    const applyFilters = () => {
        const query = String(form.querySelector("[name='q']")?.value || "").toLowerCase().trim();
        const operacion = String(form.querySelector("[name='operacion']")?.value || "").toLowerCase();
        const tipo = String(form.querySelector("[name='tipo']")?.value || "").toLowerCase();
        const ubicacion = String(form.querySelector("[name='ubicacion']")?.value || "").toLowerCase().trim();
        const precio = String(form.querySelector("[name='precio']")?.value || "");
        const habitaciones = String(form.querySelector("[name='habitaciones']")?.value || "");

        cards.forEach((card) => {
            const title = String(card.dataset.title || "").toLowerCase();
            const cardOperacion = String(card.dataset.operation || "").toLowerCase();
            const cardTipo = String(card.dataset.type || "").toLowerCase();
            const cardUbicacion = String(card.dataset.location || "").toLowerCase();
            const cardPrice = Number(card.dataset.price || 0);
            const cardBedrooms = Number(card.dataset.bedrooms || 0);
            const matchesQuery = !query || title.includes(query) || cardUbicacion.includes(query);
            const matchesOperacion = !operacion || operacion === "todas" || cardOperacion === operacion;
            const matchesTipo = !tipo || tipo === "todos" || cardTipo === tipo;
            const matchesUbicacion = !ubicacion || cardUbicacion.includes(ubicacion);
            const matchesPrecio =
                !precio ||
                (precio === "0-150000" && cardPrice <= 150000) ||
                (precio === "150000-250000" && cardPrice > 150000 && cardPrice <= 250000) ||
                (precio === "250000-400000" && cardPrice > 250000 && cardPrice <= 400000) ||
                (precio === "400000+" && cardPrice > 400000);
            const matchesBedrooms = !habitaciones || habitaciones === "cualquiera" || cardBedrooms >= Number(habitaciones);

            card.hidden = !(matchesQuery && matchesOperacion && matchesTipo && matchesUbicacion && matchesPrecio && matchesBedrooms);
        });
    };

    form.addEventListener("submit", (event) => {
        event.preventDefault();
        applyFilters();
    });

    form.querySelectorAll("input, select").forEach((input) => {
        input.addEventListener("input", applyFilters);
        input.addEventListener("change", applyFilters);
    });
});
