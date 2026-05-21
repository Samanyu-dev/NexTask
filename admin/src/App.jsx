import { useEffect, useMemo, useState } from 'react';

const tokenKey = 'nextask_admin_token';
const statusOptions = [
  { value: '', label: 'All statuses' },
  { value: 'pending', label: 'Pending' },
  { value: 'in_progress', label: 'In Progress' },
  { value: 'completed', label: 'Completed' },
];

function inferApiBaseUrl() {
  const explicit = import.meta.env.VITE_API_BASE_URL;
  if (explicit) {
    return explicit.replace(/\/$/, '');
  }

  const { hostname, origin, port } = window.location;
  if (
    hostname === 'localhost' ||
    hostname === '127.0.0.1' ||
    hostname === '0.0.0.0'
  ) {
    if (port === '8000') {
      return origin;
    }
    return 'http://127.0.0.1:8000';
  }

  return origin;
}

const apiBaseUrl = inferApiBaseUrl();

function cleanMessage(error) {
  if (error instanceof Error && error.message) {
    return error.message;
  }
  return 'Something went wrong. Please try again.';
}

async function apiRequest(path, { method = 'GET', token, body } = {}) {
  const response = await fetch(`${apiBaseUrl}${path}`, {
    method,
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    let message = 'Request failed';
    try {
      const payload = await response.json();
      if (payload?.detail) {
        message = payload.detail;
      }
    } catch (_) {
      message = response.statusText || message;
    }
    throw new Error(message);
  }

  if (response.status === 204) {
    return null;
  }

  const contentType = response.headers.get('content-type') || '';
  if (contentType.includes('application/json')) {
    return response.json();
  }

  return null;
}

function formatDate(value) {
  if (!value) {
    return 'No due date';
  }

  try {
    return new Intl.DateTimeFormat('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    }).format(new Date(value));
  } catch (_) {
    return value;
  }
}

function statusLabel(value) {
  return value
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function priorityTone(priority) {
  if (priority === 'high') return 'high';
  if (priority === 'low') return 'low';
  return 'medium';
}

export default function App() {
  const [token, setToken] = useState(() => localStorage.getItem(tokenKey) || '');
  const [currentUser, setCurrentUser] = useState(null);
  const [summary, setSummary] = useState(null);
  const [users, setUsers] = useState([]);
  const [tasks, setTasks] = useState([]);
  const [activeTab, setActiveTab] = useState('tasks');
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [userFilter, setUserFilter] = useState('');
  const [authForm, setAuthForm] = useState({ email: '', password: '' });
  const [isAuthenticating, setIsAuthenticating] = useState(false);
  const [isBootstrapping, setIsBootstrapping] = useState(Boolean(token));
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');

  const selectedUserName = useMemo(() => {
    const user = users.find((item) => String(item.id) === String(userFilter));
    return user?.name ?? 'All owners';
  }, [userFilter, users]);

  useEffect(() => {
    if (!token) {
      setCurrentUser(null);
      setIsBootstrapping(false);
      return;
    }

    let cancelled = false;

    async function restore() {
      setIsBootstrapping(true);
      try {
        const me = await apiRequest('/auth/me', { token });
        if (cancelled) {
          return;
        }
        if (!me.is_admin) {
          throw new Error('This account is not an admin account.');
        }
        setCurrentUser(me);
      } catch (restoreError) {
        if (!cancelled) {
          localStorage.removeItem(tokenKey);
          setToken('');
          setCurrentUser(null);
          setError(cleanMessage(restoreError));
        }
      } finally {
        if (!cancelled) {
          setIsBootstrapping(false);
        }
      }
    }

    restore();

    return () => {
      cancelled = true;
    };
  }, [token]);

  useEffect(() => {
    if (!currentUser?.is_admin || !token) {
      return;
    }

    refreshDashboard();
  }, [currentUser, token, search, statusFilter, userFilter]);

  async function refreshDashboard() {
    setIsRefreshing(true);
    setError('');

    try {
      const [summaryData, userData, taskData] = await Promise.all([
        apiRequest('/admin-api/summary', { token }),
        apiRequest('/admin-api/users', { token }),
        apiRequest(
          `/admin-api/tasks?${new URLSearchParams({
            ...(search ? { search } : {}),
            ...(statusFilter ? { status: statusFilter } : {}),
            ...(userFilter ? { user_id: userFilter } : {}),
          }).toString()}`,
          { token },
        ),
      ]);

      setSummary(summaryData);
      setUsers(userData);
      setTasks(taskData);
    } catch (refreshError) {
      setError(cleanMessage(refreshError));
    } finally {
      setIsRefreshing(false);
    }
  }

  async function handleLogin(event) {
    event.preventDefault();
    setError('');
    setNotice('');
    setIsAuthenticating(true);

    try {
      const payload = await apiRequest('/auth/login', {
        method: 'POST',
        body: authForm,
      });
      localStorage.setItem(tokenKey, payload.access_token);
      setToken(payload.access_token);
      setNotice('Admin login successful.');
    } catch (loginError) {
      setError(cleanMessage(loginError));
    } finally {
      setIsAuthenticating(false);
    }
  }

  function handleLogout() {
    localStorage.removeItem(tokenKey);
    setToken('');
    setCurrentUser(null);
    setSummary(null);
    setUsers([]);
    setTasks([]);
    setError('');
    setNotice('Logged out.');
  }

  async function handleTaskStatusChange(taskId, nextStatus) {
    setError('');
    setNotice('');

    try {
      await apiRequest(`/admin-api/tasks/${taskId}/status`, {
        method: 'PATCH',
        token,
        body: { status: nextStatus },
      });
      setNotice('Task status updated.');
      await refreshDashboard();
    } catch (updateError) {
      setError(cleanMessage(updateError));
    }
  }

  async function handleDeleteTask(taskId) {
    if (!window.confirm('Delete this task permanently?')) {
      return;
    }

    setError('');
    setNotice('');

    try {
      await apiRequest(`/admin-api/tasks/${taskId}`, {
        method: 'DELETE',
        token,
      });
      setNotice('Task deleted.');
      await refreshDashboard();
    } catch (deleteError) {
      setError(cleanMessage(deleteError));
    }
  }

  async function handleDeleteUser(userId, userName) {
    if (!window.confirm(`Delete ${userName} and all of their tasks?`)) {
      return;
    }

    setError('');
    setNotice('');

    try {
      await apiRequest(`/admin-api/users/${userId}`, {
        method: 'DELETE',
        token,
      });
      setNotice('User deleted.');
      await refreshDashboard();
    } catch (deleteError) {
      setError(cleanMessage(deleteError));
    }
  }

  if (!token || !currentUser) {
    return (
      <div className="page-shell">
        <div className="ambient ambient-one" />
        <div className="ambient ambient-two" />
        <main className="auth-layout">
          <section className="hero-panel">
            <p className="eyebrow">Bonus Admin Dashboard</p>
            <h1>NexTask control room for people, progress, and priorities.</h1>
            <p className="hero-copy">
              Review all users, monitor every task, update statuses in place,
              and keep the system tidy before your assessment demo.
            </p>
            <div className="hero-grid">
              <div className="stat-tile">
                <span>Live overview</span>
                <strong>Users + tasks</strong>
              </div>
              <div className="stat-tile">
                <span>Fast actions</span>
                <strong>Status + delete</strong>
              </div>
            </div>
          </section>

          <section className="login-panel">
            <div className="panel-head">
              <p className="eyebrow">Admin Sign In</p>
              <h2>Secure access only</h2>
            </div>

            <form className="stack" onSubmit={handleLogin}>
              <label className="field">
                <span>Email</span>
                <input
                  type="email"
                  value={authForm.email}
                  onChange={(event) =>
                    setAuthForm((current) => ({
                      ...current,
                      email: event.target.value,
                    }))
                  }
                  placeholder="admin@example.com"
                  required
                />
              </label>

              <label className="field">
                <span>Password</span>
                <input
                  type="password"
                  value={authForm.password}
                  onChange={(event) =>
                    setAuthForm((current) => ({
                      ...current,
                      password: event.target.value,
                    }))
                  }
                  placeholder="Enter admin password"
                  required
                />
              </label>

              {error ? <div className="banner error">{error}</div> : null}
              {notice ? <div className="banner success">{notice}</div> : null}

              <button className="primary-button" type="submit" disabled={isAuthenticating || isBootstrapping}>
                {isAuthenticating || isBootstrapping ? 'Checking access...' : 'Enter dashboard'}
              </button>
            </form>
          </section>
        </main>
      </div>
    );
  }

  return (
    <div className="page-shell">
      <div className="ambient ambient-one" />
      <div className="ambient ambient-two" />
      <main className="dashboard-layout">
        <header className="masthead">
          <div>
            <p className="eyebrow">Admin Dashboard</p>
            <h1>Operational visibility across the full task system.</h1>
            <p className="masthead-copy">
              Signed in as {currentUser.name}. Use search, status filters, and
              owner filters to review work across every employee.
            </p>
          </div>
          <div className="header-actions">
            <button className="ghost-button" type="button" onClick={refreshDashboard}>
              {isRefreshing ? 'Refreshing...' : 'Refresh'}
            </button>
            <button className="primary-button" type="button" onClick={handleLogout}>
              Logout
            </button>
          </div>
        </header>

        {error ? <div className="banner error">{error}</div> : null}
        {notice ? <div className="banner success">{notice}</div> : null}

        <section className="summary-grid">
          <SummaryCard label="Users" value={summary?.total_users ?? 0} />
          <SummaryCard label="Tasks" value={summary?.total_tasks ?? 0} accent="amber" />
          <SummaryCard label="Pending" value={summary?.pending_tasks ?? 0} accent="brown" />
          <SummaryCard label="In Progress" value={summary?.in_progress_tasks ?? 0} accent="blue" />
          <SummaryCard label="Completed" value={summary?.completed_tasks ?? 0} accent="green" />
          <SummaryCard label="Admins" value={summary?.admin_users ?? 0} />
        </section>

        <section className="control-strip">
          <div className="segmented">
            <button
              type="button"
              className={activeTab === 'tasks' ? 'segmented-active' : ''}
              onClick={() => setActiveTab('tasks')}
            >
              Tasks
            </button>
            <button
              type="button"
              className={activeTab === 'users' ? 'segmented-active' : ''}
              onClick={() => setActiveTab('users')}
            >
              Users
            </button>
          </div>

          <div className="search-row">
            <label className="search-shell">
              <span>Search tasks or owners</span>
              <input
                value={search}
                onChange={(event) => setSearch(event.target.value)}
                placeholder="Search title, description, owner name, or email"
              />
            </label>

            <label className="select-shell">
              <span>Status</span>
              <select
                value={statusFilter}
                onChange={(event) => setStatusFilter(event.target.value)}
              >
                {statusOptions.map((option) => (
                  <option key={option.value || 'all'} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </label>

            <label className="select-shell">
              <span>Owner</span>
              <select
                value={userFilter}
                onChange={(event) => setUserFilter(event.target.value)}
              >
                <option value="">{selectedUserName}</option>
                {users.map((user) => (
                  <option key={user.id} value={user.id}>
                    {user.name}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </section>

        {activeTab === 'tasks' ? (
          <section className="data-panel">
            <div className="panel-head">
              <div>
                <p className="eyebrow">All Tasks</p>
                <h2>Cross-team task monitor</h2>
              </div>
              <span className="pill">{tasks.length} visible</span>
            </div>

            {tasks.length === 0 ? (
              <EmptyState
                title="No tasks match this view"
                body="Try clearing a filter or broadening the search."
              />
            ) : (
              <div className="task-grid">
                {tasks.map((task) => (
                  <article key={task.id} className="task-tile">
                    <div className="tile-top">
                      <div>
                        <h3>{task.title}</h3>
                        <p className="muted">{task.user_name} · {task.user_email}</p>
                      </div>
                      <span className={`priority-pill ${priorityTone(task.priority)}`}>
                        {task.priority}
                      </span>
                    </div>

                    <p className="task-copy">
                      {task.description || 'No description provided.'}
                    </p>

                    <div className="meta-row">
                      <span className={`status-pill ${task.status}`}>{statusLabel(task.status)}</span>
                      <span className="date-pill">{formatDate(task.due_date)}</span>
                    </div>

                    <div className="tile-actions">
                      <label className="inline-select">
                        <span>Update status</span>
                        <select
                          value={task.status}
                          onChange={(event) =>
                            handleTaskStatusChange(task.id, event.target.value)
                          }
                        >
                          {statusOptions
                            .filter((option) => option.value)
                            .map((option) => (
                              <option key={option.value} value={option.value}>
                                {option.label}
                              </option>
                            ))}
                        </select>
                      </label>
                      <button
                        className="danger-button"
                        type="button"
                        onClick={() => handleDeleteTask(task.id)}
                      >
                        Delete
                      </button>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        ) : (
          <section className="data-panel">
            <div className="panel-head">
              <div>
                <p className="eyebrow">All Users</p>
                <h2>Account oversight</h2>
              </div>
              <span className="pill">{users.length} users</span>
            </div>

            {users.length === 0 ? (
              <EmptyState
                title="No users found"
                body="Once registrations happen, they will appear here."
              />
            ) : (
              <div className="user-list">
                {users.map((user) => (
                  <article key={user.id} className="user-row">
                    <div>
                      <h3>{user.name}</h3>
                      <p className="muted">{user.email}</p>
                    </div>
                    <div className="user-meta">
                      <span className="pill">{user.task_count} tasks</span>
                      {user.is_admin ? <span className="pill accent">Admin</span> : null}
                      <button
                        className="danger-button"
                        type="button"
                        onClick={() => handleDeleteUser(user.id, user.name)}
                        disabled={user.id === currentUser.id}
                      >
                        {user.id === currentUser.id ? 'Current admin' : 'Delete'}
                      </button>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>
        )}
      </main>
    </div>
  );
}

function SummaryCard({ label, value, accent = 'teal' }) {
  return (
    <article className={`summary-card ${accent}`}>
      <span>{label}</span>
      <strong>{value}</strong>
    </article>
  );
}

function EmptyState({ title, body }) {
  return (
    <div className="empty-state">
      <h3>{title}</h3>
      <p>{body}</p>
    </div>
  );
}
