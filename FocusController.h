#pragma once

#include <QObject>
#include <QTimer>

class FocusController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int  remainingSeconds READ remainingSeconds NOTIFY remainingSecondsChanged)
    Q_PROPERTY(bool running          READ running          NOTIFY runningChanged)
    Q_PROPERTY(int  totalSeconds     READ totalSeconds     WRITE setTotalSeconds NOTIFY totalSecondsChanged)
    Q_PROPERTY(QString formattedTime READ formattedTime    NOTIFY remainingSecondsChanged)

public:
    explicit FocusController(QObject *parent = nullptr);

    int  remainingSeconds() const { return m_remainingSeconds; }
    bool running()          const { return m_timer.isActive(); }
    int  totalSeconds()     const { return m_totalSeconds; }

    void setTotalSeconds(int seconds);

    Q_INVOKABLE void startSession();
    Q_INVOKABLE void pauseSession();
    Q_INVOKABLE void resumeSession();
    Q_INVOKABLE void resetSession();

    QString formattedTime() const;

signals:
    void remainingSecondsChanged();
    void runningChanged();
    void totalSecondsChanged();
    void sessionFinished();

private slots:
    void tick();

private:
    QTimer m_timer;
    int    m_totalSeconds;      // default 9 h = 32400 s
    int    m_remainingSeconds;
};
