#include "SessionModel.h"

SessionModel::SessionModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

void SessionModel::setDatabaseManager(DatabaseManager *db)
{
    m_db = db;
    if (m_db) {
        loadSessions();
    }
}

int SessionModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_sessions.size();
}

QVariant SessionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_sessions.size())
        return {};

    const Session &s = m_sessions[index.row()];
    switch (role) {
    case IdRole:        return s.id;
    case NameRole:      return s.name;
    case CreatedAtRole: return s.createdAt;
    case DurationRole:  return s.duration;
    default:            return {};
    }
}

QHash<int, QByteArray> SessionModel::roleNames() const
{
    return {
        { IdRole, "sessionId" },
        { NameRole, "sessionName" },
        { CreatedAtRole, "sessionCreatedAt" },
        { DurationRole, "sessionDuration" }
    };
}

void SessionModel::addSession(const QString &name)
{
    int newId = m_db->addSession(name);
    if (newId != -1) {
        beginInsertRows({}, 0, 0);
        m_sessions.insert(0, {newId, name, QDateTime::currentDateTime(), 32400});
        endInsertRows();
        setCurrentSessionId(newId);
    }
}

void SessionModel::removeSession(int row)
{
    if (row < 0 || row >= m_sessions.size()) return;
    int id = m_sessions[row].id;
    m_db->removeSession(id);
    beginRemoveRows({}, row, row);
    m_sessions.removeAt(row);
    endRemoveRows();
    if (m_currentSessionId == id) {
        setCurrentSessionId(m_sessions.isEmpty() ? -1 : m_sessions[0].id);
    }
}

void SessionModel::updateDuration(int row, int seconds)
{
    if (row < 0 || row >= m_sessions.size()) return;
    m_sessions[row].duration = seconds;
    m_db->updateSessionDuration(m_sessions[row].id, seconds);
    QModelIndex idx = index(row);
    emit dataChanged(idx, idx, {DurationRole});
}

int SessionModel::currentSessionId() const
{
    return m_currentSessionId;
}

void SessionModel::setCurrentSessionId(int id)
{
    if (m_currentSessionId != id) {
        m_currentSessionId = id;
        emit currentSessionIdChanged();
    }
}

int SessionModel::getDurationForId(int id) const
{
    for (const auto &s : m_sessions) {
        if (s.id == id) return s.duration;
    }
    return 32400; // default
}

void SessionModel::loadSessions()
{
    beginResetModel();
    m_sessions = m_db->getSessions();
    endResetModel();
    if (!m_sessions.isEmpty() && m_currentSessionId == -1) {
        setCurrentSessionId(m_sessions[0].id);
    }
}
