#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVector>
#include <QDateTime>
#include "TopicModel.h"

struct Session {
    int id;
    QString name;
    QDateTime createdAt;
    int duration; // in seconds
};

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    bool openDatabase();
    
    // Sessions
    QVector<Session> getSessions();
    int addSession(const QString &name);
    void removeSession(int sessionId);
    void updateSessionDuration(int sessionId, int durationSeconds);
    int getOrCreateDefaultSessionId();

    // Topics
    QVector<Topic> getTopicsForSession(int sessionId);
    void saveTopics(int sessionId, const QVector<Topic> &topics);
    void updateTopic(int sessionId, const Topic &topic);

private:
    QSqlDatabase m_db;
    bool initTables();
};
