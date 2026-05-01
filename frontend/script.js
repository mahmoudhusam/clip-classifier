/* ──────────────────────────────────────────────────────────────────────────
   CLIP Image Classifier - Frontend Script
   ────────────────────────────────────────────────────────────────────────── */

const API_BASE = 'http://localhost:5000';

// ── Global State ──────────────────────────────────────────────────────────
const state = {
  selectedFiles: [],
  labels: [],
  results: null,
  currentEnv: 'dev',
  confidenceThreshold: 0,
  exportFormat: 'json',
  isClassifying: false,
};

// ── Label Presets ─────────────────────────────────────────────────────────
const PRESETS = {
  general: ['person', 'car', 'nature', 'food', 'text or screenshot', 'animals'],
  objects: ['car', 'person', 'dog', 'cat', 'phone', 'laptop', 'book'],
  scenes: ['indoor', 'outdoor', 'nature', 'city', 'beach', 'mountain'],
  emotions: ['happy', 'sad', 'angry', 'surprised', 'neutral'],
};

// ──────────────────────────────────────────────────────────────────────────
// INITIALIZATION
// ──────────────────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  console.log('Initializing CLIP Classifier...');

  initializeDropZone();
  initializeLabelInput();
  initializeButtons();
  initializeSliders();
  initializePresets();
  loadServerInfo();
  loadDefaultLabels();

  console.log('✅ Initialization complete');
});

// ──────────────────────────────────────────────────────────────────────────
// FILE UPLOAD & DRAG-DROP
// ──────────────────────────────────────────────────────────────────────────

function initializeDropZone() {
  const dropZone = document.getElementById('dropZone');
  const fileInput = document.getElementById('fileInput');

  // Click to browse
  dropZone.addEventListener('click', () => fileInput.click());

  // Drag events
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach((eventName) => {
    dropZone.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  dropZone.addEventListener('dragenter', () =>
    dropZone.classList.add('dragover'),
  );
  dropZone.addEventListener('dragleave', () =>
    dropZone.classList.remove('dragover'),
  );
  dropZone.addEventListener('dragover', () =>
    dropZone.classList.add('dragover'),
  );

  dropZone.addEventListener('drop', (e) => {
    dropZone.classList.remove('dragover');
    const files = e.dataTransfer.files;
    handleFiles(files);
  });

  // File input change
  fileInput.addEventListener('change', (e) => {
    handleFiles(e.target.files);
  });
}

function handleFiles(files) {
  const newFiles = Array.from(files).filter((file) =>
    file.type.startsWith('image/'),
  );

  if (newFiles.length === 0) {
    showAlert('No valid image files selected', 'warning');
    return;
  }

  state.selectedFiles.push(...newFiles);
  updateFilesList();
  updateClassifyButtonState();
}

function updateFilesList() {
  const filesList = document.getElementById('filesList');
  const filesContainer = document.getElementById('filesContainer');
  const fileCount = document.getElementById('fileCount');

  fileCount.textContent = state.selectedFiles.length;

  filesContainer.innerHTML = state.selectedFiles
    .map(
      (file, index) => `
        <div class="list-group-item">
            <div class="file-item-name">
                <i class="bi bi-image"></i>
                <span>${file.name}</span>
            </div>
            <span class="text-muted small">${formatFileSize(file.size)}</span>
            <i class="bi bi-x-lg file-item-remove" onclick="removeFile(${index})"></i>
        </div>
    `,
    )
    .join('');

  filesList.style.display = state.selectedFiles.length > 0 ? 'block' : 'none';
}

function removeFile(index) {
  state.selectedFiles.splice(index, 1);
  updateFilesList();
  updateClassifyButtonState();
}

function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i];
}

// ──────────────────────────────────────────────────────────────────────────
// LABELS MANAGEMENT
// ──────────────────────────────────────────────────────────────────────────

function initializeLabelInput() {
  const labelInput = document.getElementById('labelInput');
  const addLabelBtn = document.getElementById('addLabelBtn');

  addLabelBtn.addEventListener('click', () => addLabel(labelInput.value));
  labelInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      addLabel(labelInput.value);
    }
  });
}

function addLabel(label) {
  const trimmedLabel = label.trim().toLowerCase();

  if (!trimmedLabel) {
    showAlert('Label cannot be empty', 'warning');
    return;
  }

  if (state.labels.includes(trimmedLabel)) {
    showAlert('Label already exists', 'info');
    return;
  }

  state.labels.push(trimmedLabel);
  document.getElementById('labelInput').value = '';
  updateLabelsList();
  updateClassifyButtonState();
}

function removeLabel(index) {
  state.labels.splice(index, 1);
  updateLabelsList();
  updateClassifyButtonState();
}

function updateLabelsList() {
  const labelsContainer = document.getElementById('labelsContainer');

  if (state.labels.length === 0) {
    labelsContainer.innerHTML =
      '<span class="text-muted small">No labels added yet. Add at least 2 labels to classify.</span>';
    return;
  }

  labelsContainer.innerHTML = state.labels
    .map(
      (label, index) => `
        <span class="label-badge">
            ${label}
            <i class="bi bi-x-lg" onclick="removeLabel(${index})" style="cursor: pointer;"></i>
        </span>
    `,
    )
    .join('');
}

function loadDefaultLabels() {
  const defaultLabels = PRESETS.general.slice(0, 3);
  state.labels = defaultLabels;
  updateLabelsList();
  updateClassifyButtonState();
}

function setPreset(presetName) {
  state.labels = [...PRESETS[presetName]];
  updateLabelsList();
  updateClassifyButtonState();
}

function initializePresets() {
  document.querySelectorAll('.preset-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const preset = btn.dataset.preset;
      setPreset(preset);
      showAlert(`Loaded ${preset} preset labels`, 'info');
    });
  });
}

// ──────────────────────────────────────────────────────────────────────────
// BUTTONS & CONTROLS
// ──────────────────────────────────────────────────────────────────────────

function initializeButtons() {
  document
    .getElementById('classifyBtn')
    .addEventListener('click', classifyImages);
  document.getElementById('resetBtn').addEventListener('click', resetForm);
  document
    .getElementById('clearFilesBtn')
    .addEventListener('click', clearFiles);
  document
    .getElementById('downloadBtn')
    .addEventListener('click', downloadResults);
  document.getElementById('copyBtn').addEventListener('click', copyToClipboard);
  document
    .getElementById('envSelect')
    .addEventListener('change', switchEnvironment);
}

function updateClassifyButtonState() {
  const btn = document.getElementById('classifyBtn');
  const isValid = state.selectedFiles.length > 0 && state.labels.length >= 2;
  btn.disabled = !isValid || state.isClassifying;
}

function clearFiles() {
  state.selectedFiles = [];
  document.getElementById('labelInput').value = '';
  updateFilesList();
  updateClassifyButtonState();
}

function resetForm() {
  state.selectedFiles = [];
  state.labels = [];
  state.results = null;
  document.getElementById('resultsSection').style.display = 'none';
  document.getElementById('fileInput').value = '';
  updateFilesList();
  updateLabelsList();
  updateClassifyButtonState();
}

// ──────────────────────────────────────────────────────────────────────────
// SLIDERS & SETTINGS
// ──────────────────────────────────────────────────────────────────────────

function initializeSliders() {
  const confidenceSlider = document.getElementById('confidenceSlider');
  const confidenceValue = document.getElementById('confidenceValue');
  const exportFormat = document.getElementById('exportFormat');

  confidenceSlider.addEventListener('input', (e) => {
    state.confidenceThreshold = parseInt(e.target.value);
    confidenceValue.textContent = state.confidenceThreshold + '%';
    // Re-display results if they exist
    if (state.results && !(state.results instanceof Blob)) {
      displayResults();
    }
  });

  exportFormat.addEventListener('change', (e) => {
    state.exportFormat = e.target.value;
  });
}

// ──────────────────────────────────────────────────────────────────────────
// SERVER COMMUNICATION
// ──────────────────────────────────────────────────────────────────────────

async function loadServerInfo() {
  try {
    const response = await fetch(`${API_BASE}/info`);
    const data = await response.json();

    const statusDiv = document.getElementById('serverStatus');
    statusDiv.innerHTML = `
            <strong>Server Status:</strong><br>
            Model: ${data.model}<br>
            Device: ${data.device}<br>
            Supported Formats: ${data.supported_formats.length}
        `;
    statusDiv.className = 'alert alert-success';
  } catch (error) {
    document.getElementById('serverStatus').innerHTML = `
            <strong>Server Error:</strong> Unable to connect to server at ${API_BASE}<br>
            Make sure the backend is running: <code>python -m uvicorn backend.app:app --reload</code>
        `;
    document.getElementById('serverStatus').className = 'alert alert-danger';
  }
}

async function switchEnvironment(env) {
  try {
    const response = await fetch(`${API_BASE}/config/env`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `env=${env.target.value}`,
    });

    if (response.ok) {
      state.currentEnv = env.target.value;
      document.getElementById('envBadge').textContent = env.target.value;
      showAlert(`Switched to ${env.target.value} environment`, 'success');
      loadServerInfo();
    }
  } catch (error) {
    showAlert('Failed to switch environment', 'danger');
  }
}

async function classifyImages() {
  if (state.selectedFiles.length === 0 || state.labels.length < 2) {
    showAlert('Please add files and labels', 'warning');
    return;
  }

  state.isClassifying = true;
  updateClassifyButtonState();

  // Show progress
  document.getElementById('progressContainer').style.display = 'block';
  document.getElementById('progressBar').style.width = '0%';
  document.getElementById('resultsSection').style.display = 'none';

  try {
    const formData = new FormData();

    // Add files
    state.selectedFiles.forEach((file) => {
      formData.append('files', file);
    });

    // Add labels
    formData.append('labels', state.labels.join(','));

    // Add options
    formData.append('export_format', state.exportFormat);

    // Update progress
    let progress = 0;
    const progressInterval = setInterval(() => {
      progress = Math.min(progress + Math.random() * 30, 90);
      updateProgress(progress);
    }, 500);

    // Send request
    console.log('Sending classification request...');
    const response = await fetch(`${API_BASE}/classify`, {
      method: 'POST',
      body: formData,
    });

    clearInterval(progressInterval);

    if (!response.ok) {
      let errorMessage = 'Classification failed';
      try {
        const errorData = await response.json();
        errorMessage = errorData.detail || errorMessage;
      } catch (e) {
        errorMessage = `HTTP ${response.status}: ${response.statusText}`;
      }
      throw new Error(errorMessage);
    }

    // Handle different export formats
    if (state.exportFormat === 'json') {
      const data = await response.json();
      state.results = data;
    } else {
      // For binary formats, store the blob
      const blob = await response.blob();
      state.results = blob;
    }

    updateProgress(100);

    setTimeout(() => {
      document.getElementById('progressContainer').style.display = 'none';
      displayResults();
    }, 500);

    showAlert('Classification complete!', 'success');
  } catch (error) {
    console.error('Classification error:', error);
    showAlert(`Error: ${error.message}`, 'danger');
    document.getElementById('progressContainer').style.display = 'none';
  } finally {
    state.isClassifying = false;
    updateClassifyButtonState();
  }
}

function updateProgress(percent) {
  const bar = document.getElementById('progressBar');
  const text = document.getElementById('progressText');
  bar.style.width = percent + '%';
  text.textContent = Math.round(percent) + '%';
}

// ──────────────────────────────────────────────────────────────────────────
// RESULTS DISPLAY
// ──────────────────────────────────────────────────────────────────────────

function displayResults() {
  if (!state.results) return;

  const resultsSection = document.getElementById('resultsSection');
  const resultsSummary = document.getElementById('resultsSummary');
  const resultsDetails = document.getElementById('resultsDetails');

  // For non-JSON formats, just show a message
  if (state.results instanceof Blob) {
    resultsSummary.innerHTML = `
            <div class="alert alert-info">
                <i class="bi bi-check-circle"></i> Classification complete!
                Results are ready to download in ${state.exportFormat.toUpperCase()} format.
            </div>
        `;
    resultsDetails.innerHTML = '';
    resultsSection.style.display = 'block';
    return;
  }

  // Filter results by confidence threshold
  const filteredResults = state.results.filter(
    (r) => r.top_score >= state.confidenceThreshold,
  );

  // For JSON, display detailed results
  const groupedResults = groupByLabel(filteredResults);

  // Summary
  const totalProcessed = state.results.length;
  const totalShown = filteredResults.length;
  const avgConfidence =
    filteredResults.length > 0
      ? (
          filteredResults.reduce((sum, r) => sum + r.top_score, 0) /
          filteredResults.length
        ).toFixed(1)
      : 0;

  resultsSummary.innerHTML = `
        <h5 class="mb-3">Summary</h5>
        <div class="row">
            <div class="col-md-4">
                <div class="card text-white bg-info">
                    <div class="card-body">
                        <h6>Images Shown</h6>
                        <h3>${totalShown}/${totalProcessed}</h3>
                        <small>${state.confidenceThreshold > 0 ? `(filtered ≥${state.confidenceThreshold}%)` : '(all)'}</small>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-white bg-primary">
                    <div class="card-body">
                        <h6>Categories</h6>
                        <h3>${Object.keys(groupedResults).length}</h3>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-white bg-success">
                    <div class="card-body">
                        <h6>Avg Confidence</h6>
                        <h3>${avgConfidence}%</h3>
                    </div>
                </div>
            </div>
        </div>
    `;

  // Details by category
  let detailsHTML = '<h5 class="mt-4 mb-3">Results by Category</h5>';

  if (filteredResults.length === 0) {
    detailsHTML +=
      '<p class="text-muted">No results match the confidence threshold of ' +
      state.confidenceThreshold +
      '%</p>';
  } else {
    Object.entries(groupedResults).forEach(([label, files]) => {
      detailsHTML += `
              <div class="result-category">
                  <div class="result-category-header">
                      <i class="bi bi-folder"></i> ${label.toUpperCase()} (${files.length})
                  </div>
          `;

      files.forEach((file) => {
        const result = filteredResults.find((r) => r.filename === file);
        if (result) {
          const scoreClass =
            result.top_score >= 80
              ? 'score-high'
              : result.top_score >= 50
                ? 'score-medium'
                : 'score-low';

          detailsHTML += `
                  <div class="result-item">
                      <span class="result-filename">
                          <i class="bi bi-image"></i> ${file}
                      </span>
                      <span class="result-score ${scoreClass}">${result.top_score}%</span>
                  </div>
              `;
        }
      });

      detailsHTML += '</div>';
    });
  }

  resultsDetails.innerHTML = detailsHTML;
  resultsSection.style.display = 'block';
  resultsSection.scrollIntoView({ behavior: 'smooth' });
}

function groupByLabel(results) {
  const grouped = {};
  results.forEach((result) => {
    const label = result.top_label;
    if (!grouped[label]) {
      grouped[label] = [];
    }
    grouped[label].push(result.filename);
  });
  return grouped;
}

// ──────────────────────────────────────────────────────────────────────────
// EXPORT & DOWNLOAD
// ──────────────────────────────────────────────────────────────────────────

function downloadResults() {
  if (!state.results) {
    showAlert('No results to download', 'warning');
    return;
  }

  let filename = 'results';
  let content;
  let mimeType;

  if (state.results instanceof Blob) {
    // Binary format (already downloaded from API)
    const extension =
      state.exportFormat === 'excel' ? 'xlsx' : state.exportFormat;
    const url = URL.createObjectURL(state.results);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${filename}.${extension}`;
    a.click();
    URL.revokeObjectURL(url);
  } else {
    // JSON format
    content = JSON.stringify(state.results, null, 2);
    mimeType = 'application/json';
    filename += '.json';

    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
  }

  showAlert('Results downloaded!', 'success');
}

function copyToClipboard() {
  if (!state.results || state.results instanceof Blob) {
    showAlert('Cannot copy binary format to clipboard', 'warning');
    return;
  }

  const text = JSON.stringify(state.results, null, 2);
  navigator.clipboard
    .writeText(text)
    .then(() => {
      showAlert('Results copied to clipboard!', 'success');
    })
    .catch(() => {
      showAlert('Failed to copy to clipboard', 'danger');
    });
}

// ──────────────────────────────────────────────────────────────────────────
// ALERTS
// ──────────────────────────────────────────────────────────────────────────

function showAlert(message, type = 'info') {
  const alertContainer = document.getElementById('alertContainer');
  const alertId = 'alert-' + Date.now();

  const alertHTML = `
        <div id="${alertId}" class="alert alert-${type} alert-dismissible fade show m-3" role="alert">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;

  alertContainer.insertAdjacentHTML('beforeend', alertHTML);

  // Auto-remove after 5 seconds
  setTimeout(() => {
    const alert = document.getElementById(alertId);
    if (alert) {
      alert.remove();
    }
  }, 5000);
}
