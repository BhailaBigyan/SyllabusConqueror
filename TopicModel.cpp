#include "TopicModel.h"
#include "DatabaseManager.h"

TopicModel::TopicModel(QObject *parent)
    : QAbstractListModel(parent)
{}

void TopicModel::setDatabaseManager(DatabaseManager *db)
{
    if (m_db != db) {
        m_db = db;
        m_sessionId = m_db ? m_db->getOrCreateDefaultSessionId() : -1;
        loadTopics();
    }
}

int TopicModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_topics.size();
}

QVariant TopicModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_topics.size())
        return {};

    const Topic &t = m_topics[index.row()];
    switch (role) {
    case NameRole:    return t.name;
    case MarksRole:   return t.marks;
    case CheckedRole: return t.checked;
    default:          return {};
    }
}

bool TopicModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_topics.size())
        return false;

    Topic &t = m_topics[index.row()];
    if (role == CheckedRole) {
        t.checked = value.toBool();
        emit dataChanged(index, index, {CheckedRole});
        emit marksChanged();
        saveToDb();
        return true;
    } else if (role == NameRole) {
        t.name = value.toString();
        emit dataChanged(index, index, {NameRole});
        saveToDb();
        return true;
    } else if (role == MarksRole) {
        t.marks = value.toInt();
        emit dataChanged(index, index, {MarksRole});
        emit marksChanged();
        saveToDb();
        return true;
    }
    return false;
}

Qt::ItemFlags TopicModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsUserCheckable | Qt::ItemIsEditable;
}

QHash<int, QByteArray> TopicModel::roleNames() const
{
    return {
        { NameRole,    "topicName" },
        { MarksRole,   "topicMarks" },
        { CheckedRole, "topicChecked" }
    };
}

int TopicModel::totalMarks() const
{
    int total = 0;
    for (const auto &t : m_topics)
        total += t.marks;
    return total;
}

int TopicModel::securedMarks() const
{
    int secured = 0;
    for (const auto &t : m_topics)
        if (t.checked) secured += t.marks;
    return secured;
}

int TopicModel::sessionId() const
{
    return m_sessionId;
}

void TopicModel::setSessionId(int id)
{
    if (m_sessionId != id) {
        m_sessionId = id;
        loadTopics();
        emit sessionIdChanged();
    }
}

void TopicModel::addTopic(const QString &name, int marks)
{
    if (name.trimmed().isEmpty() || marks < 0) return;
    if (!m_db || m_sessionId == -1) return; // ensure we only add when a valid session is active
    beginInsertRows({}, m_topics.size(), m_topics.size());
    m_topics.append({ name.trimmed(), marks, false });
    endInsertRows();
    emit marksChanged();
    saveToDb();
}

void TopicModel::removeTopic(int row)
{
    if (row < 0 || row >= m_topics.size()) return;
    beginRemoveRows({}, row, row);
    m_topics.removeAt(row);
    endRemoveRows();
    emit marksChanged();
    saveToDb();
}

void TopicModel::toggleChecked(int row)
{
    if (row < 0 || row >= m_topics.size()) return;
    m_topics[row].checked = !m_topics[row].checked;
    QModelIndex idx = index(row);
    emit dataChanged(idx, idx, {CheckedRole});
    emit marksChanged();
    saveToDb();
}

void TopicModel::clearAll()
{
    beginResetModel();
    m_topics.clear();
    endResetModel();
    emit marksChanged();
    saveToDb();
}

void TopicModel::loadTopics()
{
    beginResetModel();
    if (m_db && m_sessionId != -1) {
        m_topics = m_db->getTopicsForSession(m_sessionId);
    } else {
        m_topics.clear();
    }
    endResetModel();
    emit marksChanged();
}

void TopicModel::saveToDb()
{
    if (m_db && m_sessionId != -1) {
        m_db->saveTopics(m_sessionId, m_topics);
    }
}

void TopicModel::updateTopicName(int row, const QString &name)
{
    if (row < 0 || row >= m_topics.size()) return;
    QString n = name.trimmed();
    if (n.isEmpty()) return;
    m_topics[row].name = n;
    QModelIndex idx = index(row);
    emit dataChanged(idx, idx, {NameRole});
    saveToDb();
}

void TopicModel::updateTopicMarks(int row, int marks)
{
    if (row < 0 || row >= m_topics.size()) return;
    if (marks < 0 || marks > 100) return;
    m_topics[row].marks = marks;
    QModelIndex idx = index(row);
    emit dataChanged(idx, idx, {MarksRole});
    emit marksChanged();
    saveToDb();
}
