#include "DatabaseManager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    openDatabase();
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::openDatabase()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(path + "/syllabus_conqueror.db");

    if (!m_db.open()) {
        qWarning() << "Error: connection with database fail" << m_db.lastError();
        return false;
    }

    return initTables();
}

bool DatabaseManager::initTables()
{
    QSqlQuery query;
    bool ok = query.exec("CREATE TABLE IF NOT EXISTS sessions ("
                         "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                         "name TEXT, "
                         "created_at DATETIME, "
                         "duration INTEGER DEFAULT 32400)"); // default 9h
    if (!ok) return false;

    // Ensure duration column exists (for existing databases)
    query.exec("ALTER TABLE sessions ADD COLUMN duration INTEGER DEFAULT 32400");

    ok = query.exec("CREATE TABLE IF NOT EXISTS topics ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "session_id INTEGER, "
                    "name TEXT, "
                    "marks INTEGER, "
                    "checked BOOLEAN, "
                    "FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE)");
    return ok;
}

QVector<Session> DatabaseManager::getSessions()
{
    QVector<Session> sessions;
    QSqlQuery query("SELECT id, name, created_at, duration FROM sessions ORDER BY created_at DESC");
    while (query.next()) {
        sessions.append({query.value(0).toInt(), query.value(1).toString(), query.value(2).toDateTime(), query.value(3).toInt()});
    }
    return sessions;
}

int DatabaseManager::addSession(const QString &name)
{
    QSqlQuery query;
    query.prepare("INSERT INTO sessions (name, created_at, duration) VALUES (?, ?, ?)");
    query.addBindValue(name);
    query.addBindValue(QDateTime::currentDateTime());
    query.addBindValue(32400); // Default duration 9h
    if (query.exec()) {
        return query.lastInsertId().toInt();
    }
    return -1;
}

void DatabaseManager::removeSession(int sessionId)
{
    QSqlQuery query;
    query.prepare("DELETE FROM sessions WHERE id = ?");
    query.addBindValue(sessionId);
    query.exec();
}

void DatabaseManager::updateSessionDuration(int sessionId, int durationSeconds)
{
    QSqlQuery query;
    query.prepare("UPDATE sessions SET duration = ? WHERE id = ?");
    query.addBindValue(durationSeconds);
    query.addBindValue(sessionId);
    query.exec();
}

int DatabaseManager::getOrCreateDefaultSessionId()
{
    QSqlQuery query;
    query.prepare("SELECT id FROM sessions WHERE name = ?");
    query.addBindValue("Default");
    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }
    query.prepare("INSERT INTO sessions (name, created_at, duration) VALUES (?, ?, ?)");
    query.addBindValue("Default");
    query.addBindValue(QDateTime::currentDateTime());
    query.addBindValue(32400);
    if (query.exec()) {
        return query.lastInsertId().toInt();
    }
    return -1;
}

QVector<Topic> DatabaseManager::getTopicsForSession(int sessionId)
{
    QVector<Topic> topics;
    QSqlQuery query;
    query.prepare("SELECT name, marks, checked FROM topics WHERE session_id = ?");
    query.addBindValue(sessionId);
    if (query.exec()) {
        while (query.next()) {
            topics.append({query.value(0).toString(), query.value(1).toInt(), query.value(2).toBool()});
        }
    }
    return topics;
}

void DatabaseManager::saveTopics(int sessionId, const QVector<Topic> &topics)
{
    m_db.transaction();
    QSqlQuery query;
    query.prepare("DELETE FROM topics WHERE session_id = ?");
    query.addBindValue(sessionId);
    query.exec();

    query.prepare("INSERT INTO topics (session_id, name, marks, checked) VALUES (?, ?, ?, ?)");
    for (const auto &t : topics) {
        query.addBindValue(sessionId);
        query.addBindValue(t.name);
        query.addBindValue(t.marks);
        query.addBindValue(t.checked);
        query.exec();
    }
    m_db.commit();
}

void DatabaseManager::updateTopic(int sessionId, const Topic &topic)
{
    // Simplified: we'll just re-save topics for now when changes occur, or implement individual updates
}
