#pragma once

#include <QAbstractListModel>
#include <QVector>
#include <QString>
#include <QObject>

struct Topic {
    QString name;
    int marks;
    bool checked;
};

class DatabaseManager;

class TopicModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int totalMarks   READ totalMarks   NOTIFY marksChanged)
    Q_PROPERTY(int securedMarks READ securedMarks NOTIFY marksChanged)
    Q_PROPERTY(int sessionId    READ sessionId    WRITE setSessionId NOTIFY sessionIdChanged)

public:
    enum TopicRoles {
        NameRole    = Qt::UserRole + 1,
        MarksRole,
        CheckedRole
    };

    explicit TopicModel(QObject *parent = nullptr);

    Q_INVOKABLE void setDatabaseManager(DatabaseManager *db);
    Q_INVOKABLE void setSessionId(int id);

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int, QByteArray> roleNames() const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    int totalMarks() const;
    int securedMarks() const;
    int sessionId() const;

    Q_INVOKABLE void addTopic(const QString &name, int marks);
    Q_INVOKABLE void removeTopic(int row);
    Q_INVOKABLE void toggleChecked(int row);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE void updateTopicName(int row, const QString &name);
    Q_INVOKABLE void updateTopicMarks(int row, int marks);

signals:
    void marksChanged();
    void sessionIdChanged();

private:
    QVector<Topic> m_topics;
    DatabaseManager *m_db = nullptr;
    int m_sessionId = -1;

    void loadTopics();
    void saveToDb();
};
