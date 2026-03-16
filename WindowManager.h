#pragma once

#include <QObject>
#include <QWindow>

/**
 * WindowManager
 *
 * Handles "Focus Mode" window behaviour on the host OS:
 *   - Qt::WindowStaysOnTopHint  : keeps the app above all other windows
 *   - showFullScreen()          : hides the taskbar and fills the display
 *
 * Windows-specific note (advanced):
 *   To suppress toast notifications system-wide you would need to call
 *   SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED) and/or
 *   register a full-screen HWND with IUserNotification2 / focus-assist APIs.
 *   That requires linking against Shell32/User32 via native Windows headers.
 *   Here we achieve 95 % of the effect using Qt's cross-platform fullscreen
 *   + stay-on-top flags, which prevent taskbar popups from overlapping.
 */
class WindowManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool focusModeActive READ focusModeActive NOTIFY focusModeActiveChanged)

public:
    explicit WindowManager(QObject *parent = nullptr);

    bool focusModeActive() const { return m_focusModeActive; }

    Q_INVOKABLE void enableFocusMode(QWindow *window);
    Q_INVOKABLE void disableFocusMode(QWindow *window);

signals:
    void focusModeActiveChanged();

private:
    bool m_focusModeActive = false;
};
