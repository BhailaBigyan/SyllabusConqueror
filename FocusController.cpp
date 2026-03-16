#include "FocusController.h"

static constexpr int DEFAULT_SECONDS = 9 * 60 * 60; // 9 hours

FocusController::FocusController(QObject *parent)
    : QObject(parent)
    , m_totalSeconds(DEFAULT_SECONDS)
    , m_remainingSeconds(DEFAULT_SECONDS)
{
    connect(&m_timer, &QTimer::timeout, this, &FocusController::tick);
    m_timer.setInterval(1000);
    m_timer.setTimerType(Qt::PreciseTimer);
}

void FocusController::setTotalSeconds(int seconds)
{
    if (seconds <= 0 || seconds == m_totalSeconds) return;
    m_totalSeconds = seconds;
    emit totalSecondsChanged();
    resetSession();
}

void FocusController::startSession()
{
    m_remainingSeconds = m_totalSeconds;
    emit remainingSecondsChanged();
    if (!m_timer.isActive()) {
        m_timer.start();
        emit runningChanged();
    }
}

void FocusController::pauseSession()
{
    if (m_timer.isActive()) {
        m_timer.stop();
        emit runningChanged();
    }
}

void FocusController::resumeSession()
{
    if (!m_timer.isActive() && m_remainingSeconds > 0) {
        m_timer.start();
        emit runningChanged();
    }
}

void FocusController::resetSession()
{
    m_timer.stop();
    m_remainingSeconds = m_totalSeconds;
    emit remainingSecondsChanged();
    emit runningChanged();
}

QString FocusController::formattedTime() const
{
    int h = m_remainingSeconds / 3600;
    int m = (m_remainingSeconds % 3600) / 60;
    int s = m_remainingSeconds % 60;
    return QString("%1:%2:%3")
        .arg(h, 2, 10, QLatin1Char('0'))
        .arg(m, 2, 10, QLatin1Char('0'))
        .arg(s, 2, 10, QLatin1Char('0'));
}

void FocusController::tick()
{
    if (m_remainingSeconds > 0) {
        --m_remainingSeconds;
        emit remainingSecondsChanged();
    } else {
        m_timer.stop();
        emit runningChanged();
        emit sessionFinished();
    }
}
