class AppUi {
    constructor() {
        this.businessKey = null;
        this.businessName = '';
        this.jobTitle = '';
        this.theme = {};
        this.applicantApplications = [];
        this.managementApplications = [];
        this.selectedApplicantId = null;
        this.selectedManagementId = null;

        this.portalOverlay = document.getElementById('portal-overlay');
        this.managementOverlay = document.getElementById('management-overlay');
        this.form = document.getElementById('application-form');

        this.bindEvents();
        this.setupMessages();
        this.setupCounters();
    }

    bindEvents() {
        document.getElementById('close-portal').addEventListener('click', () => this.closePortal(true));
        document.getElementById('cancel-portal').addEventListener('click', () => this.closePortal(true));
        document.getElementById('submit-application').addEventListener('click', () => this.submitApplication());
        document.getElementById('refresh-myapps').addEventListener('click', () => this.loadApplicantApplications());
        document.querySelectorAll('.side-btn').forEach((btn) => btn.addEventListener('click', () => this.switchTab(btn.dataset.tab)));

        document.getElementById('close-management').addEventListener('click', () => this.closeManagement());
        document.getElementById('refresh-management').addEventListener('click', () => this.refreshManagement());
        document.getElementById('management-search').addEventListener('input', () => this.renderManagementList());
        document.getElementById('management-status-filter').addEventListener('change', () => this.renderManagementList());
        document.getElementById('save-application').addEventListener('click', () => this.saveManagementUpdate());

        document.addEventListener('keydown', (event) => {
            if (event.key !== 'Escape') return;
            if (!this.portalOverlay.classList.contains('hidden')) this.closePortal(true);
            if (!this.managementOverlay.classList.contains('hidden')) this.closeManagement();
        });
    }

    setupMessages() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            if (data.type === 'openPortal') {
                this.openPortal(data.businessKey, data.businessName, data.jobTitle, data.theme || {});
            } else if (data.type === 'closePortal') {
                this.hidePortalOnly();
            } else if (data.type === 'openManagement') {
                this.openManagement(data.businessKey, data.businessName, data.applications || []);
            } else if (data.type === 'closeManagement') {
                this.hideManagementOnly();
            }
        });
    }

    setupCounters() {
        [['motivation', 'motivation-count'], ['references', 'references-count']].forEach(([fieldName, counterId]) => {
            const field = this.form.querySelector(`[name="${fieldName}"]`);
            const counter = document.getElementById(counterId);
            if (!field || !counter) return;
            const update = () => { counter.textContent = field.value.length; };
            field.addEventListener('input', update);
            update();
        });
    }

    switchTab(tab) {
        document.querySelectorAll('.side-btn').forEach((btn) => btn.classList.toggle('active', btn.dataset.tab === tab));
        document.querySelectorAll('.tab-panel').forEach((panel) => panel.classList.add('hidden'));
        document.getElementById(`tab-${tab}`).classList.remove('hidden');
        if (tab === 'myapps') this.loadApplicantApplications();
    }

    openPortal(businessKey, businessName, jobTitle, theme) {
        this.businessKey = businessKey;
        this.businessName = businessName;
        this.jobTitle = jobTitle;
        this.theme = theme || {};
        this.selectedApplicantId = null;
        this.applyTheme();
        this.portalOverlay.classList.remove('hidden');
        document.getElementById('portal-title').textContent = businessName;
        document.getElementById('portal-job-title').textContent = jobTitle;
        document.getElementById('apply-heading').textContent = `${jobTitle} Application`;
        document.getElementById('portal-headline').textContent = this.theme.headline || 'Apply, track updates, and check your interview details.';
        document.getElementById('portal-badge').textContent = this.theme.badge || 'Applications';
        document.getElementById('portal-business-icon').innerHTML = `<i class="${this.theme.icon || 'fa-solid fa-file-signature'}"></i>`;
        this.switchTab('apply');
        this.loadApplicantApplications();
    }

    applyTheme() {
        const root = document.documentElement;
        root.style.setProperty('--accent', this.theme.accent || '#3b82f6');
        root.style.setProperty('--accent-soft', this.theme.accentSoft || 'rgba(59,130,246,0.18)');
        root.style.setProperty('--panel-1', this.theme.panel || '#0f172a');
        root.style.setProperty('--panel-2', this.theme.panel2 || '#111827');
    }

    hidePortalOnly() {
        this.portalOverlay.classList.add('hidden');
        this.form.reset();
        this.clearErrors();
        this.setupCounters();
    }

    closePortal(notifyGame = false) {
        this.hidePortalOnly();
        if (notifyGame) {
            fetch(`https://${GetParentResourceName()}/cancelPortal`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({})
            }).catch(() => {});
        }
    }

    clearErrors() {
        this.form.querySelectorAll('.field-group').forEach((group) => group.classList.remove('error'));
        this.form.querySelectorAll('.error-message').forEach((el) => el.textContent = '');
    }

    validateForm() {
        const rules = {
            fullName: (v) => v.trim().length >= 2,
            age: (v) => Number(v) >= 16 && Number(v) <= 90,
            dateOfBirth: (v) => !!v,
            phone: (v) => v.trim().length >= 3,
            gender: (v) => !!v,
            discord: (v) => v.trim().length >= 2,
            discordId: (v) => /^\d+$/.test(v.trim()),
            experience: (v) => !!v,
            availability: (v) => !!v,
            motivation: (v) => v.trim().length >= 50,
        };
        let valid = true;
        this.clearErrors();
        Object.entries(rules).forEach(([name, check]) => {
            const field = this.form.querySelector(`[name="${name}"]`);
            if (!field) return;
            if (!check(field.value || '')) {
                const group = field.closest('.field-group');
                group.classList.add('error');
                group.querySelector('.error-message').textContent = name === 'motivation' ? 'Give them something real â€” at least 50 characters.' : 'Fill this in properly.';
                valid = false;
            }
        });
        return valid;
    }

    getFormData() {
        const formData = new FormData(this.form);
        const out = {};
        formData.forEach((value, key) => out[key] = value);
        return out;
    }

    async submitApplication() {
        if (!this.validateForm()) {
            this.notify('Fix the marked fields first.', 'error');
            return;
        }
        const button = document.getElementById('submit-application');
        const original = button.innerHTML;
        button.disabled = true;
        button.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Submitting...';
        try {
            await fetch(`https://${GetParentResourceName()}/submitApplication`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ data: this.getFormData(), businessKey: this.businessKey })
            });
            this.notify('Application submitted. Come back here to track it.', 'success');
            this.form.reset();
            this.setupCounters();
            this.loadApplicantApplications();
            this.switchTab('myapps');
        } catch (e) {
            console.error(e);
            this.notify('Failed to submit application.', 'error');
        }
        button.disabled = false;
        button.innerHTML = original;
    }

    async loadApplicantApplications() {
        try {
            const response = await fetch(`https://${GetParentResourceName()}/fetchApplicantApplications`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ businessKey: this.businessKey })
            });
            const data = await response.json();
            if (!data.success) {
                this.notify(data.message || 'Failed to load your applications.', 'error');
                return;
            }
            this.applicantApplications = data.applications || [];
            document.getElementById('previous-count-copy').textContent = this.applicantApplications.length
                ? `${this.applicantApplications.length} previous application${this.applicantApplications.length > 1 ? 's' : ''} on file for this business.`
                : 'No previous applications on file.';
            this.renderApplicantList();
            if (this.selectedApplicantId) this.selectApplicantApplication(this.selectedApplicantId);
        } catch (e) {
            console.error(e);
            this.notify('Failed to load your applications.', 'error');
        }
    }

    renderApplicantList() {
        const wrap = document.getElementById('myapps-list');
        if (!this.applicantApplications.length) {
            wrap.innerHTML = '<div class="empty-mini">No applications yet. Submit one and it will live here.</div>';
            document.getElementById('myapps-empty').classList.remove('hidden');
            document.getElementById('myapps-detail').classList.add('hidden');
            return;
        }
        wrap.innerHTML = this.applicantApplications.map((app) => `
            <button class="list-card ${app.id === this.selectedApplicantId ? 'active' : ''}" data-id="${app.id}">
                <div>
                    <strong>${app.jobTitle}</strong>
                    <p>${app.createdAt}</p>
                </div>
                <div class="list-card-right">
                    ${app.unreadApplicantUpdates ? `<span class="mini-badge">${app.unreadApplicantUpdates}</span>` : ''}
                    <span class="status-pill ${app.status}">${app.status}</span>
                </div>
            </button>
        `).join('');
        wrap.querySelectorAll('.list-card').forEach((btn) => btn.addEventListener('click', () => this.selectApplicantApplication(btn.dataset.id)));
    }

    async selectApplicantApplication(id) {
        this.selectedApplicantId = id;
        const app = this.applicantApplications.find((entry) => entry.id === id);
        if (!app) return;

        document.getElementById('myapps-empty').classList.add('hidden');
        document.getElementById('myapps-detail').classList.remove('hidden');
        document.getElementById('myapp-name').textContent = `${app.businessName} â€” ${app.jobTitle}`;
        document.getElementById('myapp-meta').textContent = `Submitted ${app.createdAt} â€¢ Previous applications here: ${app.previousCount || 0}`;
        document.getElementById('myapp-status').className = `status-pill ${app.status}`;
        document.getElementById('myapp-status').textContent = app.status;

        const notice = document.getElementById('myapp-notice');
        const visibleUpdate = app.management?.applicantNotes || '';
        if (visibleUpdate) {
            notice.classList.remove('hidden');
            notice.textContent = visibleUpdate;
        } else {
            notice.classList.add('hidden');
            notice.textContent = '';
        }

        const detailGrid = document.getElementById('myapp-detail-grid');
        const cards = [
            ['Experience', app.applicant.experience],
            ['Availability', app.applicant.availability],
            ['Interview Time', app.management?.interviewAt || 'Not set'],
            ['Interview Location', app.management?.interviewLocation || 'Not set'],
            ['Interview Instructions', app.management?.interviewInstructions || app.management?.interviewNotes || 'No interview instructions yet.'],
            ['Last Updated', `${app.management?.updatedAt || app.createdAt} by ${app.management?.updatedBy || 'System'}`],
            ['Motivation', app.applicant.motivation],
            ['References', app.applicant.references || 'None']
        ];
        detailGrid.innerHTML = cards.map(([label, value]) => `
            <div class="card detail-card ${['Motivation','References','Interview Instructions'].includes(label) ? 'full-span' : ''}">
                <span>${label}</span>
                <p>${value}</p>
            </div>`).join('');

        document.getElementById('myapp-history').innerHTML = (app.history || []).slice().reverse().map((entry) => `
            <div class="timeline-entry">
                <div class="timeline-dot"></div>
                <div>
                    <strong>${entry.action}</strong>
                    <p>${entry.note || 'No extra note.'}</p>
                    <span>${entry.at} â€¢ ${entry.by || 'System'}</span>
                </div>
            </div>`).join('');

        this.renderApplicantList();

        if (app.unreadApplicantUpdates) {
            try {
                const response = await fetch(`https://${GetParentResourceName()}/markApplicantUpdatesRead`, {
                    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id })
                });
                const data = await response.json();
                if (data.success && data.application) {
                    const idx = this.applicantApplications.findIndex((entry) => entry.id === id);
                    if (idx !== -1) this.applicantApplications[idx] = data.application;
                    this.renderApplicantList();
                }
            } catch (e) {
                console.error(e);
            }
        }
    }

    openManagement(businessKey, businessName, applications) {
        this.businessKey = businessKey;
        this.managementApplications = applications || [];
        this.selectedManagementId = null;
        document.getElementById('management-title').textContent = `${businessName || 'Applications'} Manager`;
        this.managementOverlay.classList.remove('hidden');
        this.renderManagementList();
        this.showManagementEmpty();
    }

    hideManagementOnly() {
        this.managementOverlay.classList.add('hidden');
        this.selectedManagementId = null;
    }

    closeManagement() {
        this.hideManagementOnly();
        fetch(`https://${GetParentResourceName()}/closeManagement`, {
            method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({})
        }).catch(() => {});
    }

    getFilteredManagementApplications() {
        const search = document.getElementById('management-search').value.trim().toLowerCase();
        const status = document.getElementById('management-status-filter').value;
        return this.managementApplications.filter((app) => {
            const matchesStatus = status === 'all' || app.status === status;
            const haystack = [app.applicant.fullName, app.applicant.discord, app.applicant.phone, app.jobTitle, app.status].join(' ').toLowerCase();
            return matchesStatus && (!search || haystack.includes(search));
        }).sort((a,b) => (a.createdAt < b.createdAt ? 1 : -1));
    }

    renderManagementList() {
        const wrap = document.getElementById('applications-list');
        const rows = this.getFilteredManagementApplications();
        if (!rows.length) {
            wrap.innerHTML = '<div class="empty-mini">No applications found.</div>';
            return;
        }
        wrap.innerHTML = rows.map((app) => `
            <button class="list-card ${app.id === this.selectedManagementId ? 'active' : ''}" data-id="${app.id}">
                <div>
                    <strong>${app.applicant.fullName}</strong>
                    <p>${app.jobTitle} â€¢ prev: ${app.previousCount || 0}</p>
                </div>
                <span class="status-pill ${app.status}">${app.status}</span>
            </button>`).join('');
        wrap.querySelectorAll('.list-card').forEach((btn) => btn.addEventListener('click', () => this.selectManagementApplication(btn.dataset.id)));
    }

    selectManagementApplication(id) {
        this.selectedManagementId = id;
        const app = this.managementApplications.find((entry) => entry.id === id);
        if (!app) return;
        document.getElementById('application-empty').classList.add('hidden');
        document.getElementById('application-detail').classList.remove('hidden');
        document.getElementById('detail-name').textContent = app.applicant.fullName;
        document.getElementById('detail-meta').textContent = `${app.jobTitle} â€¢ ${app.businessName} â€¢ submitted ${app.createdAt}`;
        document.getElementById('detail-status').className = `status-pill ${app.status}`;
        document.getElementById('detail-status').textContent = app.status;

        document.getElementById('manager-status').value = app.status;
        document.getElementById('manager-interview-at').value = app.management?.interviewAt || '';
        document.getElementById('manager-interview-location').value = app.management?.interviewLocation || '';
        document.getElementById('manager-applicant-notes').value = app.management?.applicantNotes || '';
        document.getElementById('manager-interview-notes').value = app.management?.interviewNotes || '';
        document.getElementById('manager-notes').value = app.management?.managerNotes || '';

        const sameApplicant = this.managementApplications.filter((entry) => entry.applicant.license === app.applicant.license);
        const detailCards = [
            ['Phone', app.applicant.phone],
            ['Discord', `${app.applicant.discord} (${app.applicant.discordId})`],
            ['Age / DOB', `${app.applicant.age} â€¢ ${app.applicant.dateOfBirth}`],
            ['Gender', app.applicant.gender],
            ['Availability', app.applicant.availability],
            ['Experience', app.applicant.experience],
            ['Previous Applications', `${sameApplicant.length - 1 < 0 ? 0 : sameApplicant.length - 1}`],
            ['Last Updated', `${app.management?.updatedAt || app.createdAt} by ${app.management?.updatedBy || 'System'}`],
            ['Motivation', app.applicant.motivation],
            ['References', app.applicant.references || 'None'],
        ];
        document.getElementById('detail-grid').innerHTML = detailCards.map(([label, value]) => `
            <div class="card detail-card ${['Motivation','References'].includes(label) ? 'full-span' : ''}">
                <span>${label}</span><p>${value}</p>
            </div>`).join('');

        document.getElementById('manager-history').innerHTML = (app.history || []).slice().reverse().map((entry) => `
            <div class="timeline-entry">
                <div class="timeline-dot"></div>
                <div>
                    <strong>${entry.action}</strong>
                    <p>${entry.note || 'No extra note.'}</p>
                    <span>${entry.at} â€¢ ${entry.by || 'System'}</span>
                </div>
            </div>`).join('');

        this.renderManagementList();
    }

    showManagementEmpty() {
        document.getElementById('application-empty').classList.remove('hidden');
        document.getElementById('application-detail').classList.add('hidden');
    }

    async refreshManagement() {
        try {
            const response = await fetch(`https://${GetParentResourceName()}/fetchManagementApplications`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ businessKey: this.businessKey })
            });
            const data = await response.json();
            if (!data.success) {
                this.notify(data.message || 'Failed to load applications.', 'error');
                return;
            }
            this.managementApplications = data.applications || [];
            this.renderManagementList();
            if (this.selectedManagementId) this.selectManagementApplication(this.selectedManagementId);
        } catch (e) {
            console.error(e);
            this.notify('Failed to refresh applications.', 'error');
        }
    }

    async saveManagementUpdate() {
        if (!this.selectedManagementId) {
            this.notify('Select an application first.', 'error');
            return;
        }
        const payload = {
            id: this.selectedManagementId,
            status: document.getElementById('manager-status').value,
            interviewAt: document.getElementById('manager-interview-at').value,
            interviewLocation: document.getElementById('manager-interview-location').value,
            applicantNotes: document.getElementById('manager-applicant-notes').value,
            interviewNotes: document.getElementById('manager-interview-notes').value,
            managerNotes: document.getElementById('manager-notes').value,
        };
        try {
            const response = await fetch(`https://${GetParentResourceName()}/updateApplicationStatus`, {
                method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload)
            });
            const data = await response.json();
            if (!data.success) {
                this.notify(data.message || 'Failed to save update.', 'error');
                return;
            }
            const idx = this.managementApplications.findIndex((entry) => entry.id === data.application.id);
            if (idx !== -1) this.managementApplications[idx] = data.application;
            this.selectManagementApplication(data.application.id);
            this.notify('Application updated.', 'success');
        } catch (e) {
            console.error(e);
            this.notify('Failed to save update.', 'error');
        }
    }

    notify(message, type='info') {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        document.body.appendChild(toast);
        requestAnimationFrame(() => toast.classList.add('show'));
        setTimeout(() => { toast.classList.remove('show'); setTimeout(() => toast.remove(), 220); }, 2200);
    }
}

document.addEventListener('DOMContentLoaded', () => { window.techApplicationUi = new AppUi(); });
