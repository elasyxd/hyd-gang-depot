let currentView = 'inventory';
let allItems = { inventory: [], stash: [] };
let weights = { inventory: { current: 0, max: 0 }, stash: { current: 0, max: 0 } };
let selectedItem = null;

$(document).ready(function () {
    console.log("[hyd-gang-depot] UI Initialized.");

    window.addEventListener('message', function (event) {
        const item = event.data;

        if (item.action === "display") {
            if (item.status) {
                $("#wrapper").fadeIn(150);
            } else {
                $("#wrapper").fadeOut(150);
                $("#transfer-modal").hide();
            }
        }

        if (item.action === "update") {
            console.log("[hyd-gang-depot] Received Data Update", item);
            allItems.inventory = item.inventory || [];
            allItems.stash = item.stash || [];
            weights.inventory = item.invWeights || { current: 0, max: 1 };
            weights.stash = item.stashWeights || { current: 0, max: 1 };
            renderItems();
            updateStats();
        }
    });

    $("#close-btn").click(closeUI);

    $("#toggle-view-btn").click(function () {
        currentView = (currentView === 'inventory') ? 'stash' : 'inventory';
        $(this).text(currentView === 'inventory' ? 'DEPOYA DÖN' : 'ENVANTERE DÖN');
        $("#ui-title").text(currentView === 'inventory' ? 'ENVANTERİN' : 'DEPO İÇERİĞİ');
        renderItems();
    });

    $("#search-input").on("input", renderItems);

    // Modal Control
    $("#close-modal").click(() => $("#transfer-modal").fadeOut(150));

    $(".quick-btn").click(function () {
        const val = $(this).data('val');
        $("#transfer-amount").val(val);
    });

    $("#set-max-btn").click(function () {
        if (selectedItem) {
            $("#transfer-amount").val(selectedItem.count);
        }
    });

    $("#confirm-transfer-btn").click(function () {
        if (!selectedItem) return;
        const amount = parseInt($("#transfer-amount").val());
        if (isNaN(amount) || amount <= 0) return;

        $.post(`https://${GetParentResourceName()}/transferItem`, JSON.stringify({
            name: selectedItem.name,
            count: amount,
            from: currentView
        }));

        $("#transfer-modal").fadeOut(150);
    });

    document.onkeyup = function (data) {
        if (data.which == 27) {
            if ($("#transfer-modal").is(":visible")) {
                $("#transfer-modal").fadeOut(150);
            } else {
                closeUI();
            }
        }
    };
});

function closeUI() {
    $("#wrapper").fadeOut(150);
    $("#transfer-modal").hide();
    $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
}

function updateStats() {
    $("#depo-label").text(`Depo: ${Math.max(0, weights.stash.current).toFixed(2)}kg / ${weights.stash.max.toFixed(2)}kg`);
    $("#depo-progress").css("width", `${Math.min(100, (Math.max(0, weights.stash.current) / weights.stash.max) * 100)}%`);

    $("#sen-label").text(`Sen: ${Math.max(0, weights.inventory.current).toFixed(2)}kg / ${weights.inventory.max.toFixed(2)}kg`);
    $("#sen-progress").css("width", `${Math.min(100, (Math.max(0, weights.inventory.current) / weights.inventory.max) * 100)}%`);
}

function renderItems() {
    const grid = $("#items-grid");
    grid.empty();

    const searchText = $("#search-input").val().toLowerCase();
    const items = allItems[currentView];

    if (!items) return;

    items.forEach(item => {
        if (item.label.toLowerCase().includes(searchText)) {
            // Priority: Server-side rarity -> Dynamic logic
            let rarityText = (item.rarity || 'COMMON').toUpperCase();

            // Auto fallback mapping for weight-based rarity if COMMON
            if (rarityText === 'COMMON') {
                const w = Number(item.weight) || 0;
                if (w >= 5000) rarityText = 'MYTHIC';
                else if (w >= 3000) rarityText = 'EPIC';
                else if (w >= 2000) rarityText = 'RARE';
                else if (w >= 500) rarityText = 'UNCOMMON';
            }

            let rarityClass = 'rarity-' + rarityText.toLowerCase();

            // Enhanced Error Handling for Images
            const card = $(`
                <div class="item-card ${rarityClass}" data-name="${item.name}">
                    <div class="item-badge-left">${item.count}x</div>
                    <div class="item-badge-right">${rarityText}</div>
                    
                    <div class="item-img-box">
                        <img src="${item.image}" onerror="handleImgError(this, '${item.name}')">
                    </div>
                    
                    <div class="item-footer">
                        <div class="item-name">${item.label}</div>
                        <div class="item-subtext">${(Number(item.weight) / 1000).toFixed(2)}kg</div>
                    </div>
                </div>
            `);

            card.click(function () {
                selectedItem = item;
                $("#modal-item-name").text(item.label);
                $("#transfer-amount").val(1).focus();
                $("#transfer-modal").css("display", "flex").hide().fadeIn(150);
            });

            grid.append(card);
        }
    });
}

function handleImgError(img, itemName) {
    if (img.getAttribute('data-fallback-step') === null) {
        img.setAttribute('data-fallback-step', '1');
        // Step 1: Try swapping extension (.webp <-> .png)
        if (img.src.includes('.webp')) img.src = img.src.replace('.webp', '.png');
        else if (img.src.includes('.png')) img.src = img.src.replace('.png', '.webp');
        else img.src = img.src + '.png';
        return;
    }

    const step = parseInt(img.getAttribute('data-fallback-step'));
    if (step === 1) {
        img.setAttribute('data-fallback-step', '2');
        // Step 2: Try ox_inventory path (Case sensitive might matter)
        img.src = `nui://ox_inventory/web/images/${itemName.toLowerCase()}.png`;
    } else if (step === 2) {
        img.setAttribute('data-fallback-step', '3');
        // Step 3: Try ox_inventory path with .webp
        img.src = `nui://ox_inventory/web/images/${itemName.toLowerCase()}.webp`;
    } else {
        // Final Fallback: Default icon
        img.onerror = null;
        img.src = 'img/WEAPON_BOTTLE.webp';
        console.warn(`[hyd-gang-depot] All fallbacks failed for ${itemName}, using default bottle icon.`);
    }
}
