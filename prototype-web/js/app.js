const TYPE_LABELS = {
  permis: '🌱 Permis de végétaliser',
  naturelle: '🌲 Zone naturelle',
  association: '🤝 Événement association',
};
const TYPE_ICON = { permis: '🌱', naturelle: '🌲', association: '🤝' };

const CATEGORY_LABELS = {
  arbre: '🌳 Arbres',
  arbuste: '🌿 Arbustes',
  fleur: '🌸 Fleurs',
  'legume-fruit': '🍅 Légumes & Fruits',
};

const STORAGE_KEY = 'tree4all_grimoire_v1';

let allZones = [];
let allEspeces = {};
let allEspecesList = [];
let allRangs = [];
let allSourcesGraines = {};
let markers = [];
let activeFilter = 'all';
let activeCategory = 'arbre';
let selectedEspeceId = null;

// ---------- État du joueur (localStorage) ----------
function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) return JSON.parse(raw);
  } catch (e) { /* ignore */ }
  return { xp: 0, plantations: [] };
}
function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}
let state = loadState();

function getRankForXp(xp) {
  let current = allRangs[0];
  let next = allRangs[1] || null;
  for (let i = 0; i < allRangs.length; i++) {
    if (xp >= allRangs[i].seuilXp) {
      current = allRangs[i];
      next = allRangs[i + 1] || null;
    }
  }
  return { current, next };
}

function updateProfileBadge() {
  const { current, next } = getRankForXp(state.xp);
  document.getElementById('profile-badge-icon').textContent = current.icone;
  let progress = 100;
  if (next) {
    const span = next.seuilXp - current.seuilXp;
    progress = Math.min(100, Math.round(((state.xp - current.seuilXp) / span) * 100));
  }
  document.getElementById('profile-badge-ring').style.setProperty('--progress', progress);
}

// ---------- Carte ----------
const map = L.map('map', {
  zoomControl: false,
  zoomAnimation: true,
  markerZoomAnimation: true,
  fadeAnimation: true,
  wheelPxPerZoomLevel: 90,
}).setView([48.86, 2.35], 12);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '&copy; OpenStreetMap contributors',
}).addTo(map);

Promise.all([
  fetch('data/zones.json').then((r) => r.json()),
  fetch('data/especes.json').then((r) => r.json()),
  fetch('data/rangs.json').then((r) => r.json()),
  fetch('data/sources-graines.json').then((r) => r.json()),
]).then(([zones, especes, rangs, sources]) => {
  allZones = zones;
  allEspecesList = especes;
  especes.forEach((e) => { allEspeces[e.id] = e; });
  allRangs = rangs;
  sources.forEach((s) => { allSourcesGraines[s.id] = s; });
  renderMarkers();
  updateProfileBadge();
});

function renderMarkers() {
  markers.forEach((m) => map.removeLayer(m));
  markers = [];
  const visibleZones = allZones.filter((z) => activeFilter === 'all' || z.type === activeFilter);
  visibleZones.forEach((zone) => {
    const icon = L.divIcon({
      className: '',
      html: `<div class="tree-marker type-${zone.type}">${TYPE_ICON[zone.type]}</div>`,
      iconSize: [38, 38],
      iconAnchor: [19, 19],
    });
    const marker = L.marker([zone.lat, zone.lng], { icon }).addTo(map);
    marker.on('click', () => openZoneSheet(zone));
    markers.push(marker);
  });
}

function seedSourcesHtml(sourceIds) {
  if (!sourceIds || !sourceIds.length) return '';
  const chips = sourceIds.map((id) => {
    const s = allSourcesGraines[id];
    if (!s) return '';
    const url = s.url || s.urlFr || null;
    const label = `${s.icone} ${s.nom}`;
    return url
      ? `<a class="seed-chip" href="${url}" target="_blank" rel="noopener">${label}</a>`
      : `<span class="seed-chip">${label}</span>`;
  }).join('');
  return `
    <div class="sheet-section-title">Où trouver les graines</div>
    <div class="seed-sources">${chips}</div>
  `;
}

function speciesCardHtml(e) {
  return `
    <div class="species-card">
      <div class="species-icon">${e.icone}</div>
      <div>
        <div class="species-name">${e.nom}</div>
        <div class="species-latin">${e.latin}</div>
        <div class="species-desc">${e.description}</div>
        <div class="species-tags">${e.tags.map((t) => `<span class="species-tag">${t}</span>`).join('')}</div>
        ${seedSourcesHtml(e.sourcesGraines)}
      </div>
    </div>`;
}

// ---------- Sheet: zone ----------
function openZoneSheet(zone) {
  const speciesHtml = zone.especes.map((id) => allEspeces[id] ? speciesCardHtml(allEspeces[id]) : '').join('');
  setSheetContent(`
    <span class="sheet-badge type-${zone.type}">${TYPE_LABELS[zone.type]}</span>
    <h2 class="sheet-title">${zone.nom}</h2>
    <div class="sheet-location">${zone.ville}, ${zone.pays}</div>
    <p class="sheet-text">${zone.description}</p>
    <div class="sheet-section-title">Règles à respecter</div>
    <div class="sheet-rules">${zone.regles}</div>
    <div class="sheet-section-title">Espèces recommandées</div>
    <div class="species-list">${speciesHtml}</div>
    <button class="sheet-cta secondary" onclick="openAddPlantation('${zone.id}')">🪄 J'ai planté ici</button>
  `);
  openSheet();
  map.flyTo([zone.lat, zone.lng], Math.max(map.getZoom(), 14), { duration: 0.7 });
}

// ---------- Sheet: grimoire (profil) ----------
function openGrimoire() {
  const { current, next } = getRankForXp(state.xp);
  let progress = 100;
  let xpText = 'Rang légendaire atteint !';
  if (next) {
    const span = next.seuilXp - current.seuilXp;
    progress = Math.min(100, Math.round(((state.xp - current.seuilXp) / span) * 100));
    xpText = `${state.xp} XP — ${next.seuilXp - state.xp} XP avant « ${next.nom} »`;
  } else {
    xpText = `${state.xp} XP`;
  }

  const entries = [...state.plantations].reverse().map((p) => {
    const e = allEspeces[p.especeId];
    if (!e) return '';
    return `
      <div class="journal-entry">
        <span class="journal-icon">${e.icone}</span>
        <div>
          <div class="journal-name">${e.nom}</div>
          <div class="journal-date">${p.date}</div>
        </div>
        <span class="journal-xp">+${p.xpGained} XP</span>
      </div>`;
  }).join('');

  setSheetContent(`
    <div class="grimoire-header">
      <span class="grimoire-rank-icon">${current.icone}</span>
      <div style="flex:1">
        <div class="grimoire-rank-name">${current.nom}</div>
        <div class="grimoire-xp-text">${xpText}</div>
        <div class="xp-bar-track"><div class="xp-bar-fill" style="width:${progress}%"></div></div>
      </div>
    </div>
    <p class="grimoire-flavor">"${current.flavor}"</p>
    <div class="sheet-section-title">Journal de plantation (${state.plantations.length})</div>
    ${entries || '<div class="journal-empty">Ton grimoire est encore vierge. Plante ta première pousse de vie !</div>'}
    <button class="sheet-cta" onclick="openAddPlantation(null)">🪄 Ajouter une plantation</button>
  `);
  openSheet();
}

// ---------- Sheet: ajouter une plantation ----------
function openAddPlantation(zoneId) {
  selectedEspeceId = null;
  activeCategory = 'arbre';
  setSheetContent(buildAddPlantationHtml(zoneId));
  openSheet();
}

function buildAddPlantationHtml(zoneId) {
  const zoneOptions = allZones.map((z) => `<option value="${z.id}" ${z.id === zoneId ? 'selected' : ''}>${z.nom} — ${z.ville}</option>`).join('');
  return `
    <span class="sheet-link-back" onclick="openGrimoire()">← Retour au grimoire</span>
    <h2 class="sheet-title">Ajouter une plantation</h2>
    <p class="sheet-text">Choisis ce que tu as planté : chaque pousse nourrit ton grimoire.</p>
    <div class="category-tabs" id="category-tabs">
      ${Object.entries(CATEGORY_LABELS).map(([key, label]) => `
        <button class="category-tab ${key === activeCategory ? 'active' : ''}" data-cat="${key}">${label}</button>
      `).join('')}
    </div>
    <div class="species-picker-grid" id="species-picker-grid"></div>
    <label class="form-label">Zone (optionnel)</label>
    <select class="form-select" id="zone-select">
      <option value="">Ailleurs / mon jardin</option>
      ${zoneOptions}
    </select>
    <button class="sheet-cta" id="confirm-plant-btn" disabled>🪄 Planter</button>
  `;
}

function renderSpeciesPicker() {
  const grid = document.getElementById('species-picker-grid');
  if (!grid) return;
  const filtered = allEspecesList.filter((e) => e.categorie === activeCategory);
  grid.innerHTML = filtered.map((e) => `
    <div class="species-pick ${e.id === selectedEspeceId ? 'selected' : ''}" data-id="${e.id}">
      <span class="species-pick-icon">${e.icone}</span>
      <span class="species-pick-name">${e.nom}</span>
    </div>
  `).join('');
  grid.querySelectorAll('.species-pick').forEach((el) => {
    el.addEventListener('click', () => {
      selectedEspeceId = el.dataset.id;
      renderSpeciesPicker();
      document.getElementById('confirm-plant-btn').disabled = false;
    });
  });
}

// ---------- Sheet: level up ----------
function showLevelUp(rang, xpGained) {
  setSheetContent(`
    <div class="levelup-wrap">
      <div class="levelup-icon">${rang.icone}</div>
      <div class="levelup-title">Nouveau rang atteint !</div>
      <div class="levelup-sub">Te voici « ${rang.nom} »</div>
      <p class="grimoire-flavor">"${rang.flavor}"</p>
      <div class="xp-toast">+${xpGained} XP</div>
      <button class="sheet-cta" onclick="openGrimoire()" style="margin-top:20px">Continuer l'aventure</button>
    </div>
  `);
  openSheet();
}

function confirmPlant() {
  if (!selectedEspeceId) return;
  const espece = allEspeces[selectedEspeceId];
  const zoneId = document.getElementById('zone-select').value || null;
  const isFirstTime = !state.plantations.some((p) => p.especeId === selectedEspeceId);
  const zoneBonus = !!zoneId;
  const multiplier = 1 + (isFirstTime ? 0.5 : 0) + (zoneBonus ? 0.2 : 0);
  const xpGained = Math.round(espece.xpBase * multiplier);

  const { current: oldRank } = getRankForXp(state.xp);
  state.xp += xpGained;
  state.plantations.push({
    especeId: selectedEspeceId,
    zoneId,
    date: new Date().toISOString().slice(0, 10),
    xpGained,
  });
  saveState(state);
  updateProfileBadge();
  const { current: newRank } = getRankForXp(state.xp);

  if (newRank.id !== oldRank.id) {
    showLevelUp(newRank, xpGained);
  } else {
    setSheetContent(`
      <div class="levelup-wrap">
        <div class="levelup-icon">${espece.icone}</div>
        <div class="levelup-title">${espece.nom} planté(e) !</div>
        <div class="xp-toast">+${xpGained} XP${isFirstTime ? ' (bonus première fois ✨)' : ''}${zoneBonus ? ' (bonus zone officielle 🛡️)' : ''}</div>
        <button class="sheet-cta" onclick="openGrimoire()" style="margin-top:20px">Voir mon grimoire</button>
      </div>
    `);
  }
}

// ---------- Sheet generic ----------
function setSheetContent(html) {
  document.getElementById('sheet-content').innerHTML = html;
  const tabs = document.getElementById('category-tabs');
  if (tabs) {
    tabs.querySelectorAll('.category-tab').forEach((btn) => {
      btn.addEventListener('click', () => {
        activeCategory = btn.dataset.cat;
        selectedEspeceId = null;
        tabs.querySelectorAll('.category-tab').forEach((b) => b.classList.remove('active'));
        btn.classList.add('active');
        renderSpeciesPicker();
        const confirmBtn = document.getElementById('confirm-plant-btn');
        if (confirmBtn) confirmBtn.disabled = true;
      });
    });
    renderSpeciesPicker();
  }
  const confirmBtn = document.getElementById('confirm-plant-btn');
  if (confirmBtn) confirmBtn.addEventListener('click', confirmPlant);
}

function openSheet() {
  document.getElementById('sheet').classList.add('open');
  document.getElementById('sheet-overlay').classList.add('visible');
}
function closeSheet() {
  document.getElementById('sheet').classList.remove('open');
  document.getElementById('sheet-overlay').classList.remove('visible');
}

document.getElementById('sheet-overlay').addEventListener('click', closeSheet);
document.getElementById('profile-badge').addEventListener('click', openGrimoire);
document.getElementById('plant-fab').addEventListener('click', () => openAddPlantation(null));

document.querySelectorAll('.filter-chip').forEach((chip) => {
  chip.addEventListener('click', () => {
    document.querySelectorAll('.filter-chip').forEach((c) => c.classList.remove('active'));
    chip.classList.add('active');
    activeFilter = chip.dataset.filter;
    renderMarkers();
  });
});

document.getElementById('locate-btn').addEventListener('click', () => {
  if (!navigator.geolocation) return;
  navigator.geolocation.getCurrentPosition((pos) => {
    map.flyTo([pos.coords.latitude, pos.coords.longitude], 14, { duration: 1 });
  });
});

document.getElementById('demo-banner-close').addEventListener('click', () => {
  document.getElementById('demo-banner').style.display = 'none';
});
