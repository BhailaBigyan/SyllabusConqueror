#pragma once

#include <QAbstractListModel>
#include <QVector>
#include <QDateTime>
#include "DatabaseManager.h"

class SessionModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentSessionId READ currentSessionId WRITE setCurrentSessionId NOTIFY currentSessionIdChanged)

public:
    enum SessionRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        CreatedAtRole,
        DurationRole
    };

    explicit SessionModel(QObject *parent = nullptr);

    void setDatabaseManager(DatabaseManager *db);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addSession(const QString &name);
    Q_INVOKABLE void removeSession(int row);
    Q_INVOKABLE void updateDuration(int row, int seconds);
    
    int currentSessionId() const;
    void setCurrentSessionId(int id);
    
    Q_INVOKABLE int getDurationForId(int id) const;

signals:
    void currentSessionIdChanged();

private:
    DatabaseManager *m_db;
    QVector<Session> m_sessions;
    int m_currentSessionId = -1;
    
    void loadSessions();
};
