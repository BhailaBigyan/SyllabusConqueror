#include "WindowManager.h"
#include <QWindow>

WindowManager::WindowManager(QObject *parent)
    : QObject(parent)
{}

void WindowManager::enableFocusMode(QWindow *window)
{
    if (!window) return;

    // Step 1: Apply "always on top" window flag.
    //         This prevents other windows (and toast notifications) from
    //         appearing on top of our app.
    Qt::WindowFlags flags = window->flags();
    flags |= Qt::WindowStaysOnTopHint;
    window->setFlags(flags);

    // Step 2: Go fullscreen so the taskbar is hidden and there are no
    //         system-level UI distractions at the edges.
    window->showFullScreen();

    m_focusModeActive = true;
    emit focusModeActiveChanged();

    /* ------------------------------------------------------------------
     * Windows-specific advanced note (not implemented here to keep the
     * code cross-platform, but provided for reference):
     *
     * #include <windows.h>
     *
     * // Hint to Windows that the display should stay on and the session
     * // is active — prevents screensaver and sleep:
     * SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED
     *                         | ES_SYSTEM_REQUIRED);
     *
     * // To activate Windows Focus Assist (Quiet Hours) programmatically
     * // you would call IFocusAssist::SetFocusAssistStatus() via COM,
     * // available from Windows 10 1903 onward.
     *
     * // To capture WM_SETFOCUS / WM_KILLFOCUS you can install a native
     * // event filter via QAbstractNativeEventFilter and inspect
     * // msg->message == WM_SETFOCUS or WM_ACTIVATE.
     * ------------------------------------------------------------------ */
}

void WindowManager::disableFocusMode(QWindow *window)
{
    if (!window) return;

    Qt::WindowFlags flags = window->flags();
    flags &= ~Qt::WindowStaysOnTopHint;
    window->setFlags(flags);

    window->showNormal();

    m_focusModeActive = false;
    emit focusModeActiveChanged();

#ifdef Q_OS_WIN
    // Restore normal execution state on Windows.
    // SetThreadExecutionState(ES_CONTINUOUS);
#endif
}
